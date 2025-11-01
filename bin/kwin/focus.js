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

const matchClassNotCaption = function (klass, caption) {
  return function(window) {
    return window.klass === klass && window.caption !== caption;
  };
}

const matchers = {
  browser: matchClassCaptionPre("firefox", "main:"),
  music: matchClassCaptionPre("firefox", "music:"),
  email: matchClassCaptionPre("firefox", "main:"),
  calendar: matchClassCaptionPre("firefox", "calendar:"),
  trello: matchClassCaptionPre("firefox", "trello:"),
  obsidianpersonal: matchClassCaptionInc("obsidian", "personal"),
  obsidianfrc: matchClassCaptionInc("obsidian", "focus-retreat-center"),
  "1password": matchClass("1Password"),
  gofi: matchClassCaption("com.mitchellh.ghostty", "gofi"),
  terminal: matchClassNotCaption("com.mitchellh.ghostty", "gofi"),
  bambustudio: matchClass("BambuStudio"),
  gedit: matchClass("org.gnome.gedit"),
  slack: matchClass("Slack"),
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
    // for simplicity the matches get plain data - no methods
    // but for setting workspace.activeWindow we need the
    // exact instance we got from the KWin API
    if (matcher(windowProps(window))) {
      print("matched: " + window.caption);
      deps.workspace.activeWindow = window;
      return;
    }
    print("window not matched: " + window.caption + " pid: " + i)
  }
};
