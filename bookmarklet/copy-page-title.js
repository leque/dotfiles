javascript:(function(){
    var t = document.createElement('textarea');
    document.body.appendChild(t);
    t.textContent = document.title + '\n' + document.URL;
    t.contentEditable = true;
    t.readOnly = false;
    t.setSelectionRange(0,65536);
    document.execCommand('copy');
    t.parentNode.removeChild(t);
})();
