const windowProps = function (windowObj) {
  return {
    klass: windowObj.resourceClass.toString(),
    caption: windowObj.caption.toString(),
    pid: windowObj.pid.toString(),
  };
};

const deps = {
  windows: workspace.windowList(),
  workspace: workspace,
};

const matchClass = function (klass) {
  return function (window) {
    return window.klass === klass;
  };
}

const matchClassCaption = function (klass, caption) {
  return function (window) {
    return window.klass === klass && window.caption === caption;
  };
}

const matchClassCaptionPre = function (klass, prefix) {
  return function (window) {
    return window.klass === klass && window.caption.startsWith(prefix);
  };
}

const matchClassCaptionInc = function (klass, substring) {
  return function (window) {
    return window.klass === klass && window.caption.includes(substring);
  };
}

const matchers = {
  browser: matchClassCaptionPre("firefox", "main:"),
  music: matchClassCaptionPre("firefox", "music:"),
  calendar: matchClassCaptionPre("firefox", "calendar:"),
  trello: matchClassCaptionPre("firefox", "trello:"),
  obsidianpersonal: matchClassCaptionInc("obsidian", "personal"),
  obsidianfrc: matchClassCaptionInc("obsidian", "focus-retreat-center"),
  "1password": matchClass("1Password"),
  gofi: matchClassCaption("com.mitchellh.ghostty", "gofi"),
  terminal: matchClass("com.mitchellh.ghostty"),
  bambustudio: matchClass("BambuStudio"),
};

const main = function (keyword, deps) {
  const matcher = matchers[keyword];
  if (!matcher) {
    print("unrecognized matcher: " + keyword);
    return;
  }
  print("deps.windows.length: " + deps.windows.length);
  for (let i = 0; i < deps.windows.length; i++) {
    const window = deps.windows[i];
    if (matcher(windowProps(window))) {
      print("matched: " + window.caption);
      deps.workspace.activeWindow = window;
      break;
    }
    print("window not matched: " + window.caption + " pid: " + i)
  };
};
