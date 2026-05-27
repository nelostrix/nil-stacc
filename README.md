# NIL ⨯ STACC

**Self-evolving AI agents for stacc robots.**

`nil-stacc` is the bridge that fuses [stacc](https://github.com/stacc-robotics) — the universal robotics development platform — with [Nil](https://github.com/nelo-robotics/nil) — the self-evolving domain agent framework. Give it any stacc `Robot`, and it returns a `RobotAgent` that can autonomously control that robot, learn from every run, and improve over time.

```
┌──────────────────────────────────────────────────────┐
│                    nil-stacc                          │
│                                                      │
│   stacc Robot ──→ bridge_tools() ──→ nil.Domain      │
│                                          │           │
│                                    nil.Agent         │
│                                    ┌─────┴─────┐     │
│                                    │ Memory    │      │
│                                    │ Evolution │      │
│                                    └─────┬─────┘     │
│                                          │            │
│                              self-improving agent     │
└──────────────────────────────────────────────────────┘
```

## Quick Start

```bash
# Requires a license key (get one at https://nelo-robotics.com/pricing)
bash install.sh --key YOUR_KEY

# Or install individual packages
bash install.sh --key YOUR_KEY --package stacc      # robotics only
bash install.sh --key YOUR_KEY --package nil-sdk     # agent SDK only
```

```python
from nil_stacc import RobotAgent
from stacc.core.urdf_parser import load_urdf

robot = load_urdf("my_robot.urdf")
agent = RobotAgent(robot)

# Every run makes the agent smarter
result = agent.run("pick up the red block from shelf A")
```

## How It Works

`nil-stacc` is a thin bridge (~260 lines) that connects two systems with zero glue code:

### `bridge_tools(robot)` — Auto-generate NIL tools from any stacc Robot

Introspects a stacc `Robot` and produces 11+ NIL-native tools:

| Tool | Description |
|------|-------------|
| `get_joint_state` | Current joint positions + velocities |
| `move_joints` | Set target joint angles (comma-separated radians) |
| `set_torques` | Apply torque values |
| `stop_robot` | Emergency stop — zero all torques |
| `get_robot_info` | Full robot structure: links, joints, DOF |
| `read_{name}` | One tool per attached sensor |
| `open_gripper` / `close_gripper` | End-effector control |
| `plan_path` | A* path planning on an occupancy grid |
| `smooth_move` | Minimum-jerk trajectory generation |
| `detect_hardware` | Detect physical hardware board (RPi, Jetson, etc.) |
| `parse_command` | Natural-language robot command parsing |

### `RobotAgent` class

Wraps a stacc `Robot` into a NIL `Agent` with continuous evolution:

```python
agent = RobotAgent(
    robot,
    model="claude-sonnet-4-20250514",          # LLM (default: Claude Sonnet 4)
    memory_path="./robot_memory",               # SQLite persistent store
    objectives=["Navigate warehouse", "Pick and place items", "Optimize routes"],
    domain_name="warehouse",
)

agent.run("inspect the storage rack and report damage")
agent.skills            # → skills the agent has learned
```

### Pre-configured agent factories

```python
from nil_stacc import warehouse_agent, inspection_agent, research_agent

agent = warehouse_agent(robot)     # warehouse logistics
agent = inspection_agent(robot)    # inspection & anomaly detection
agent = research_agent(robot)      # experiment execution & analysis
```

## The Stack

| Layer | Package | What it provides |
|-------|---------|-----------------|
| **Robotics** | `stacc` | URDF/SDF loading, kinematics (FK/IK), MuJoCo simulation, 14 sensor types, SLAM, path planning, control (PID), HAL, gaits, grippers, behavior trees, NLP |
| **Agent SDK** | `nil-sdk` | Agent kernel, multi-tier memory (working/episodic/semantic/procedural), skill extraction, textual gradient descent, causal analysis, drift detection, world modeling |
| **Bridge** | `nil-stacc` | Auto-generates tools from any stacc `Robot`, wires it into a self-evolving NIL agent with domain pre-configurations |

## Architecture

```
User: "navigate to waypoint B"
  │
  ▼
RobotAgent.run(task)
  │
  ├─ NIL Agent receives task
  │    ├─ KernelRunner executes LLM + tool calls
  │    │    ├─ move_joints()       ──→ stacc Robot
  │    │    ├─ read_lidar()        ──→ stacc Sensor
  │    │    ├─ plan_path()         ──→ stacc A* planner
  │    │    └─ parse_command()     ──→ stacc NLP parser
  │    │
  │    ├─ Tracer records experience
  │    ├─ Memory persists to SQLite
  │    └─ Evolution pipeline (continuous)
  │         ├─ Analyzer: causal patterns
  │         ├─ SkillExtractor: reusable strategies
  │         ├─ TextualGradient: improvement proposals
  │         ├─ Evaluator: A/B test candidates
  │         ├─ WorldModel: entity/tool/constraint knowledge
  │         └─ DriftDetector: performance regression check
  │
  └─ Returns result (next run is smarter)
```

## Requirements

- Python ≥ 3.9
- License key (packages are distributed as private wheels via Cloudflare R2)
- `stacc` — the robotics platform
- `nil-sdk` — the self-evolving agent SDK

## Distribution

Nil, stacc, and nil-stacc are **not on PyPI**. They are distributed privately through Cloudflare R2, gated by per-customer license keys validated against a Cloudflare Workers endpoint at `nelo-license-server.nelorobotics.workers.dev`.

## Built by

**Nelo Robotics Pvt Ltd** — Building the intelligence layer for autonomous systems.

## License

Apache 2.0
