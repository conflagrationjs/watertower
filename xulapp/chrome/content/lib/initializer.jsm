// This file is a JavaScript code module because we want this shared across all windows and JS contexts.
// See https://developer.mozilla.org/en/Using_JavaScript_code_modules for more information.
var EXPORTED_SYMBOLS = ["WaterTower"];

var WaterTower = {currentApp: null};
WaterTower.Initializer = function(appDir) {
  this.appDir = appDir.clone();
};

WaterTower.Initializer.prototype = {
  wtFileName: "config.wtjs",
  pipeDirRelativePath: "tmp/pipes",
  inputPipeName: "watertower.rackoutput.tobrowser.pipe",
  outputPipeName: "watertower.rackinput.frombrowser.pipe",
  
  bootAndSetCurrentApp: function() {
    this._checkFileStructure();
  },
  
  // Performs checks to see if we're even booting a valid WaterTower application.
  _checkFileStructure: function() {
    try {
      this._checkAppDir();
      this._checkAndSetWtFile();
      this._checkAndSetPipeDir();
      this._checkAndSetPipeFiles();
    } catch (e if e.result == Components.results.NS_ERROR_FILE_UNRECOGNIZED_PATH) {
      this._handleMissingFileException(e);
    }
  },
  
  _checkAppDir: function() {
    this.appDir.normalize(); // This will also throw if the dir does not exist.
    if (!this.appDir.exists() || !this.appDir.isDirectory()) {
      throw({name: "LoadError", message: "Application directory " + this.appDir.path + " does not exist or is not a directory."});
    }
  },
  
  _checkAndSetWtFile: function() {
    this.wtFile = this.appDir.clone();
    this.wtFile.QueryInterface(Components.interfaces.nsILocalFile).appendRelativePath(this.wtFileName);
    if (!this.wtFile.exists() || !this.wtFile.isReadable()) {
      throw({name: "LoadError", message: "WaterTower config file " + this.wtFile.path + " does not exist or is unreadable."});
    }
  },
  
  _checkAndSetPipeDir: function() {
    this.pipeDir = this.appDir.clone();
    this.pipeDir.QueryInterface(Components.interfaces.nsILocalFile).appendRelativePath(this.pipeDirRelativePath);
    if (!this.pipeDir.exists() || !this.pipeDir.isDirectory()) {
      throw({name: "LoadError", message: "WaterTower pipe directory " + this.pipeDir.path + " does not exist or is unreadable."});
    }
  },
  
  _checkAndSetPipeFiles: function() {
    this.inputPipe = this.pipeDir.clone();
    this.outputPipe = this.pipeDir.clone();
    this.inputPipe.QueryInterface(Components.interfaces.nsILocalFile).appendRelativePath(this.inputPipeName);
    this.outputPipe.QueryInterface(Components.interfaces.nsILocalFile).appendRelativePath(this.outputPipeName);
    if (!this.inputPipe.exists() || !this.inputPipe.isReadable()) {
      throw({name: "LoadError", message: "WaterTower pipe file " + this.inputPipe.path + " does not exist or is unreadable."});
    } else if (!this.outputPipe.exists() || !this.outputPipe.isWritable()) {
      throw({name: "LoadError", message: "WaterTower pipe file " + this.outputPipe.path + " does not exist or is unwritable."});
    }
  },
  
  _handleMissingFileException: function(exception) {
    throw({name: "LoadError", message: exception.message});
  }
};