(function($) {
  if (!('WebSocket' in window)) { alert("This browser does NOT support websockets and thus no bs for you :("); }

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
    $.repl.disable();
    return $.repl.log("<div class='bs_exception'>bs: websocket closed</div>");
  };
  ws.onerror = function() {
    return $.repl.log("<div class='bs_exception'>bs: websocket error</div>");
  };

  $.ws = function() { return ws };
  $.ws.bsComplete = function(val) { ws.send(':AUTOCOMPLETE: '+val); };
})(jQuery);
