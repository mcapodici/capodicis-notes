var query = { active: true, currentWindow: true };
function callback(tabs) {
  Elm.fullscreen(Elm.Main, {tabUrl: tabs[0].url, modeString: getParameterByName('mode') || 'popup'});
}
chrome.tabs.query(query, callback);

function getParameterByName(name, url) {
    if (!url) url = window.location.href;
    name = name.replace(/[\[\]]/g, "\\$&");
    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, " "));
}
