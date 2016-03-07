Elm.Native = Elm.Native || {};
Elm.Native.ExtensionStorage = {};
Elm.Native.ExtensionStorage.make = function(localRuntime){

  localRuntime.Native = localRuntime.Native || {};
  localRuntime.Native.Storage = localRuntime.Native.Storage || {};

  if (localRuntime.Native.Storage.values){
    return localRuntime.Native.Storage.values;
  }

  var Task = Elm.Native.Task.make(localRuntime);
  var Utils = Elm.Native.Utils.make(localRuntime);
  var List = Elm.Native.List.make(localRuntime);

  var get = function(key){
    return Task.asyncFunction(function(callback){
      chrome.storage.sync.get(key, function(dict){
        callback(Task.succeed(JSON.parse(dict[key])));
      })
    });
  };

  var getAll = Task.asyncFunction(function(callback){
    chrome.storage.sync.get(null, function(dict){
      // Convert each dictionary entry into a real object
      Object.keys(dict).map(function(value, index) {
        dict[value] = JSON.parse(dict[value]);
      });
      callback(Task.succeed(dict));
    })
  });

  var setItem = function(key, value){
    var keyValueObject = {}
    keyValueObject[key] = JSON.stringify(value);
    return Task.asyncFunction(function(callback){
      chrome.storage.sync.set(keyValueObject, function(){
        lastError = chrome.runtime.lastError;
        if (!lastError)
        {
          callback(Task.succeed());
        }
        else
        {
          console.log("Storage Call: set has failed with key: " + key + " error: " + lastError);
          callback(Task.fail("Storage Call: set has failed with key: " + key + " error: " + lastError));
        }
      });
    });
  };

  return {
    get       : get,
    setItem   : F2(setItem),
    getAll    : getAll
  };
};
