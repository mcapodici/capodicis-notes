var tid = setInterval( function () {
  if ( document.readyState !== 'complete' ) return;
  clearInterval( tid );

  chrome.storage.sync.get(null, function(dict){
    var links = document.links;
    for(var i = 0; i < links.length; i++) {
      var link = links[i].href;
      if (dict[link])
      {
        var data = JSON.parse(dict[link]);

        if (data && (data.n || data.d))
        {
          if (data.d)
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
          noteImage.src = chrome.extension.getURL('images/icon16.png');
          noteImage.alt = 'Note';
          noteImage.title = 'You have made a note on this page: ' + data.n;
          noteImage.style.padding = '2px 2px 2px 8px';
          insertAfter(links[i], noteImage);
        }
      }
    }
  });
}, 100 );

function insertAfter(referenceNode, newNode) {
    referenceNode.parentNode.insertBefore(newNode, referenceNode.nextSibling);
}
