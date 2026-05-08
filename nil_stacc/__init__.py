"""nil-stacc — Self-evolving AI agents for stacc robots."""

__version__ = "0.1.0"

from nil_stacc.bridge import (
    RobotAgent,
    bridge_tools,
    inspection_agent,
    research_agent,
    warehouse_agent,
)

__all__ = [
    "bridge_tools",
    "RobotAgent",
    "warehouse_agent",
    "inspection_agent",
    "research_agent",
]
