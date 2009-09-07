(function(outerScope){
  const Cc = Components.classes;
  const Ci = Components.interfaces;
  const Cr = Components.results;
  const Cu = Components.utils;
  
  Cu.import("resource://gre/modules/XPCOMUtils.jsm");
  Cu.import("resource://watertower/lib/initializer.jsm");
  
  var wtCommandLineHandler = function() {};
  wtCommandLineHandler.prototype = {
    classDescription: "WaterTower Command Line Handler",
    contractID: "@conflagrationjs.org/watertower/app-startup-clh;1",
    classID: Components.ID("{48abeaf0-9b32-11de-8a39-0800200c9a66}"),
    // FIXME - Firefox 3.5.2 has included a weird bug where getService on my
    // XPCOM component fails so the helpInfo never shows up. 
    // http://groups.google.com/group/mozilla.dev.extensions/browse_thread/thread/e505ce76e23c5289# is 
    // also experiencing this bug. So we bail in a ghetto-way and show help if we didn't get wtApp.    
    helpInfo: "  -wtApp   Path to a WaterTower application.\n",
    QueryInterface: XPCOMUtils.generateQI([Ci.nsICommandLineHandler]),
    _xpcom_categories: [{category: "command-line-handler", entry: "m-watertower"}],
    
    handle: function (cmdLine) {
      try {
        var wtAppPath = cmdLine.handleFlagWithParam("wtApp", false);
      // We got the flag with no param if this is thrown.
      } catch (e if e.result == Cr.NS_ERROR_ILLEGAL_VALUE) {
        this._handleEmptyPath();
      }
      
      if (wtAppPath) { 
        this._handleAppGiven(cmdLine.workingDirectory, wtAppPath);
      } else {
        this._handleNoAppGiven();         
      }
    },
    
    _handleEmptyPath: function() {
      dump("-wtApp was given without an argument. Please specify the path to a WaterTower runnable application.\n");
      throw(Cr.NS_ERROR_ABORT);
    },
    
    _handleNoAppGiven: function() {
      dump("Please specify the path to the root directory of a WaterTower application via -wtApp.\n");
      throw(Cr.NS_ERROR_ABORT);
    },
    
    // FIXME - We don't use nsICommandLine::resolveFile, because, well, it's fucking busted.
    // This also won't work on non-UNIXy systems.
    _handleAppGiven: function(workingDirectory, appPath) {
      if (appPath.match(/^\//)) {
        var fullAppDir = Cc["@mozilla.org/file/local;1"].createInstance(Ci.nsILocalFile);
        fullAppDir.initWithPath(appPath);
      } else {
        var fullAppDir = workingDirectory.clone();
        fullAppDir.append(appPath);
      }
      try {
        var initializer = new WaterTower.Initializer(fullAppDir);
        initializer.bootAndSetCurrentApp();
      } catch (e) {
        dump("An exception occured initializing your application: " + e.message + "\n");
        throw(Cr.NS_ERROR_ABORT);
      }
    }
  };
  
  outerScope.NSGetModule = function(compMgr, fileSpec) {
    return XPCOMUtils.generateModule([wtCommandLineHandler]);
  };
  
})(this);