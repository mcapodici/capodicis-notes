chrome.storage.sync.get(null, function(dict){
  var links = document.links;
  for(var i = 0; i < links.length; i++) {
    var link = links[i];
    if (dict[link])
    {
      var data = JSON.parse(dict[link]);

      if (data)
      {
        if (data["d"])
        {
          var tickImage = document.createElement("img");
          tickImage.src = chrome.extension.getURL('images/tick16.png');
          tickImage.alt = 'Done';
          tickImage.title = 'You have completed this note';
          tickImage.style.padding = '2px';
          insertAfter(links[i], tickImage);

          links[i].style["text-decoration"] = 'line-through';
        }

        var noteImage = document.createElement("img");
        noteImage.src = chrome.extension.getURL('images/icon19.png');
        noteImage.alt = 'Note';
        noteImage.title = 'You have made a note on this page: ' + data["n"];
        noteImage.style['padding'] = '2px 2px 2px 8px';
        insertAfter(links[i], noteImage);
      }
    }
  }
});

function insertAfter(referenceNode, newNode) {
    referenceNode.parentNode.insertBefore(newNode, referenceNode.nextSibling);
}
