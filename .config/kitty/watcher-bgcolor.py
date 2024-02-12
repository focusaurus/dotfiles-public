from typing import Any, Dict

from kitty.boss import Boss
from kitty.window import Window, DynamicColor

def on_focus_change(boss: Boss, window: Window, data: Dict[str, Any])-> None:
    if data["focused"]:
        window.change_colors({DynamicColor.default_bg: "#3c4c55"})
    else:
        window.change_colors({DynamicColor.default_bg: "#333"})
