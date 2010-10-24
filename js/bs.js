(function($) {
  if (!('WebSocket' in window)) { alert("This browser does NOT support websockets."); }

  var ws = new WebSocket("ws://127.0.0.1:8080");
  ws.onmessage = function(e) {
    var data = e.data;
    if (data.match(/^:AUTOCOMPLETE:/)) {
      var completions = $.parseJSON(data.replace(/^:AUTOCOMPLETE: /, ''));
      $.readline.finishCompletion(completions);
    } else {
      $.repl.logResult(data);
    }
  };
  ws.onclose = function() {
    return $.repl.log("!!! CLOSED !!!");
  };
  ws.onerror = function() {
    return $.repl.log("!!! ERROR !!!");
  };

  $.ws = function() { return ws };
  $.wsComplete = function(val) { ws.send(':AUTOCOMPLETE: '+val); };
})(jQuery);
