const getWindowState = function(window) {
  print("=== WINDOW STATE DEBUG ===");
  print("Window frameGeometry: " + JSON.stringify(window.frameGeometry));
  
  const x = window.frameGeometry.x;
  const width = window.frameGeometry.width;
  const height = window.frameGeometry.height;
  
  print("Analyzing: x=" + x + ", width=" + width + ", height=" + height);
  
  if (width > 1700 && height > 1000) {
    print("Detected: maximized");
    return "maximized";
  }
  
  if (width > 800 && width < 1000 && height > 1000) {
    if (x < 500) {
      print("Detected: left_half");
      return "left_half";
    } else {
      print("Detected: right_half");
      return "right_half";
    }
  }
  
  print("Detected: other");
  return "other";
};

const cycleWindowPlacement = function() {
  const activeWindow = workspace.activeWindow;
  if (!activeWindow) {
    print("No active window");
    return;
  }
  
  const currentState = getWindowState(activeWindow);
  print("Current state: " + currentState);
  
  switch (currentState) {
    case "maximized":
      print("ACTION: Setting to left half");
      activeWindow.frameGeometry = {
        x: 136,
        y: 0,
        width: 892,
        height: 1080
      };
      break;
    case "left_half":
      print("ACTION: Setting to right half");
      activeWindow.frameGeometry = {
        x: 1028,
        y: 0,
        width: 892,
        height: 1080
      };
      break;
    case "right_half":
      print("ACTION: Maximizing window");
      activeWindow.frameGeometry = {
        x: 136,
        y: 0,
        width: 1784,
        height: 1080
      };
      break;
    case "other":
    default:
      print("ACTION: Maximizing window from other state");
      activeWindow.frameGeometry = {
        x: 136,
        y: 0,
        width: 1784,
        height: 1080
      };
      break;
  }
};

cycleWindowPlacement();
