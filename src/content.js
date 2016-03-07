chrome.storage.sync.get(null, function(dict){
  var links = document.links;
  for(var i = 0; i < links.length; i++) {
    var link = links[i];
    if (dict[link])
    {
      var data = JSON.parse(dict[link]);

      if (data && data["d"])
      {
        links[i].style.backgroundColor = "#D93600";
      }
    }
  }
});
