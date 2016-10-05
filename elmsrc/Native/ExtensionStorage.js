var _mcapodici$capodicis_notes$Native_ExtensionStorage = function() {

	function getItemAsJson(key)
	{
		return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
			chrome.storage.sync.get(key, function(dict){
				callback(_elm_lang$core$Native_Scheduler.succeed(dict[key]));			
			})
		});
	}	
	
	
	var getAllAsJson = _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
			chrome.storage.sync.get(null, function(dict){
				Object.keys(dict).map(function(value, index) {
					dict[value] = JSON.parse(dict[value]);
				});
				callback(_elm_lang$core$Native_Scheduler.succeed(dict));
			});
		});	
	
	function setItem(key, value)
	{
		var keyValueObject = {}
		keyValueObject[key] = JSON.stringify(value);
		return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
			chrome.storage.sync.set(keyValueObject, function(){
				if (typeof chrome.runtime.lastError === 'undefined' || !chrome.runtime.lastError)
				{
					callback(_elm_lang$core$Native_Scheduler.succeed());
				}
				else
				{
					var lastError = chrome.runtime.lastError;
					console.log("Storage Call: set has failed with key: " + key + " error: " + lastError);
					callback(_elm_lang$core$Native_Scheduler.fail("Storage Call: set has failed with key: " + key + " error: " + lastError));
				}
			});
		});
	}
	
	return {
		getItemAsJson : getItemAsJson,
		setItem	: F2(setItem),
		getAllAsJson : getAllAsJson
	};
}();
