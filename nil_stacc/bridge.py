"""NIL-STACC bridge — connect any stacc robot to a NIL self-evolving agent."""

from __future__ import annotations

import json
from typing import Any, Callable, List, Optional

try:
    import nil

    HAS_NIL = True
except ImportError:
    HAS_NIL = False

try:
    import stacc

    HAS_STACC = True
except ImportError:
    HAS_STACC = False


def _check_deps():
    if not HAS_NIL:
        raise ImportError("nil-sdk required. Install with your license key.")
    if not HAS_STACC:
        raise ImportError("stacc required. Install with your license key.")


def bridge_tools(robot) -> List[Any]:
    """Auto-generate NIL tools from a stacc Robot."""
    _check_deps()
    tools = []

    @nil.tool
    def get_joint_state() -> str:
        """Get current joint positions and velocities."""
        pos = robot.get_joint_positions()
        vel = robot.get_joint_velocities()
        return json.dumps({"positions": pos, "velocities": vel})

    tools.append(get_joint_state)

    @nil.tool
    def move_joints(angles: str) -> str:
        """Move joints to target angles. Input: comma-separated radians."""
        try:
            a = [float(x.strip()) for x in angles.split(",")]
            robot.set_joint_positions(a)
            return f"Moved {len(a)} joints"
        except Exception as e:
            return f"Failed: {e}"

    tools.append(move_joints)

    @nil.tool
    def set_torques(torques: str) -> str:
        """Apply torques. Input: comma-separated values."""
        try:
            t = [float(x.strip()) for x in torques.split(",")]
            robot.set_joint_torques(t)
            return f"Applied {len(t)} torques"
        except Exception as e:
            return f"Failed: {e}"

    tools.append(set_torques)

    @nil.tool
    def stop_robot() -> str:
        """Emergency stop — zero all torques."""
        robot.set_joint_torques([0.0] * len(robot._state["joint_torques"]))
        return "Stopped"

    tools.append(stop_robot)

    @nil.tool
    def get_robot_info() -> str:
        """Get robot structure — links, joints, DOF."""
        return json.dumps(robot.to_dict(), indent=2)

    tools.append(get_robot_info)

    for sensor in robot.sensors:
        s = sensor
        name = s.name

        @nil.tool
        def read_sensor(sensor_name: str = name) -> str:
            f"""Read the {name} sensor."""
            try:
                data = s.read()
                clean = {
                    k: v
                    for k, v in data.items()
                    if isinstance(v, (int, float, str, bool, list))
                }
                return json.dumps(clean)
            except Exception as e:
                return f"Failed: {e}"

        read_sensor.__name__ = f"read_{name}"
        read_sensor.__doc__ = f"Read the {name} sensor."
        tools.append(read_sensor)

    if robot.end_effectors:

        @nil.tool
        def open_gripper() -> str:
            """Open the gripper."""
            robot.end_effectors[0].open()
            return "Gripper opened"

        tools.append(open_gripper)

        @nil.tool
        def close_gripper(force: float = 10.0) -> str:
            """Close the gripper."""
            robot.end_effectors[0].close(force=force)
            return f"Gripper closing with {force}N"

        tools.append(close_gripper)

    @nil.tool
    def plan_path(sx: float, sy: float, gx: float, gy: float) -> str:
        """Plan collision-free path from (sx,sy) to (gx,gy)."""
        try:
            from stacc.ai.path_planning import AStarPlanner, OccupancyGrid

            grid = OccupancyGrid(200, 200, resolution=0.05, origin=[-5, -5])
            planner = AStarPlanner(grid)
            path = planner.plan([sx, sy], [gx, gy])
            if path:
                return f"Path found: {len(path)} waypoints"
            return "No path found"
        except Exception as e:
            return f"Failed: {e}"

    tools.append(plan_path)

    @nil.tool
    def smooth_move(target_angles: str, duration: float = 2.0) -> str:
        """Move joints smoothly. target_angles: comma-separated radians."""
        try:
            from stacc.kinematics.trajectory import MinJerkTrajectory

            targets = [float(a.strip()) for a in target_angles.split(",")]
            current = robot.get_joint_positions()[: len(targets)]
            traj = MinJerkTrajectory(q_start=current, q_end=targets, duration=duration)
            return f"Trajectory created: {duration}s, {len(targets)} joints"
        except Exception as e:
            return f"Failed: {e}"

    tools.append(smooth_move)

    @nil.tool
    def detect_hardware() -> str:
        """Detect hardware platform."""
        try:
            from stacc.hal.board import Board

            board = Board.detect()
            return json.dumps(board.info())
        except Exception as e:
            return f"Failed: {e}"

    tools.append(detect_hardware)

    @nil.tool
    def parse_command(text: str) -> str:
        """Parse natural language robot command."""
        try:
            from stacc.ai.nlp import CommandParser

            cmd = CommandParser().parse(text)
            return json.dumps(cmd.to_dict())
        except Exception as e:
            return f"Failed: {e}"

    tools.append(parse_command)

    return tools


class RobotAgent:
    """Self-evolving robot agent powered by NIL + stacc."""

    def __init__(
        self,
        robot,
        model: str = "claude-sonnet-4-20250514",
        memory_path: str = "./robot_memory",
        objectives: Optional[List[str]] = None,
        domain_name: Optional[str] = None,
    ):
        _check_deps()
        self.robot = robot
        self.tools = bridge_tools(robot)
        self.domain = nil.Domain(
            name=domain_name or f"stacc-{robot.name}",
            tools=self.tools,
            objectives=objectives
            or [
                f"Control the {robot.name} robot to accomplish tasks",
                "Use sensors to perceive the environment",
                "Plan and execute movements safely",
            ],
            success_signal=lambda run: run.success,
        )
        self.agent = nil.Agent(
            domain=self.domain,
            base_model=model,
            memory=nil.PersistentMemory(memory_path),
            evolution=nil.EvolutionConfig(strategy="continuous"),
        )
        self._run_count = 0

    def run(self, task: str) -> Any:
        self._run_count += 1
        return self.agent.run(task)

    @property
    def skills(self) -> List[str]:
        if hasattr(self.agent, "memory") and hasattr(self.agent.memory, "skills"):
            return [s.name for s in self.agent.memory.skills]
        return []

    def __repr__(self):
        return f"RobotAgent('{self.robot.name}', tools={len(self.tools)}, runs={self._run_count})"


def warehouse_agent(robot, model="claude-sonnet-4-20250514") -> RobotAgent:
    return RobotAgent(
        robot,
        model=model,
        domain_name="warehouse",
        objectives=["Navigate warehouse", "Pick and place items", "Optimize routes"],
    )


def inspection_agent(robot, model="claude-sonnet-4-20250514") -> RobotAgent:
    return RobotAgent(
        robot,
        model=model,
        domain_name="inspection",
        objectives=[
            "Navigate inspection route",
            "Capture sensor data",
            "Detect anomalies",
        ],
    )


def research_agent(robot, model="claude-sonnet-4-20250514") -> RobotAgent:
    return RobotAgent(
        robot,
        model=model,
        domain_name="research",
        objectives=["Execute experiments", "Record data", "Analyze results"],
    )
