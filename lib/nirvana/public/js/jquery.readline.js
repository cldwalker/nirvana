(function($) {
  var readline_offset = search_offset = 0;
  var input, input_prompt, original_prompt, startCompletion;
  var readline_history = [];
  var original_autocomplete_options = {
    close: function(event, ui) { exit_search_history(); return true; },
    disabled: true,
    source: function(request, response) {
      return response(get_search_history(request.term));
    }
  };

  var clear_line = function () { input.val(''); };
  var previous_line = function () {
    var val = readline_history[readline_history.length - 1 - readline_offset];
    if (val) { readline_offset +=1; }
    input.val(val);
    return false;
  };
  var next_line = function () {
    var val = readline_history[readline_history.length + 1 - readline_offset];
    if (val) { readline_offset -=1; }
    input.val(val);
    return false;
  };
  var search_history = function() {
    input.autocomplete('enable');
    original_prompt = input_prompt.text();
    input_prompt.text("(search-history):");
  }
  var get_search_history = function(term) {
    var results = [];
    $.each(readline_history.reverse(), function(key,value) {
      (value.indexOf(term) != -1) && results.push(value);
    });
    return results;
  };
  var exit_search_history = function() {
    input.autocomplete('disable');
    $('ul.ui-autocomplete').hide();
    input_prompt.text(original_prompt);
  };
  var tab_complete = function() {
    input.autocomplete('enable');
    startCompletion(input.val());
    return false;
  };

  // Options:
  // * startCompletion: function to start a tab completion, given the element's current value
  // * autocompleteCss: css for jquery-ui, defaults to jquery.ui.autocomplete.css
  // * readlineCss: css for readline, defaults to jquery.readline.css
  $.fn.readline = function(options) {
    options = $.extend({
      autocompleteCss: 'jquery.ui.autocomplete.css',
      readlineCss: 'jquery.readline.css'
    }, options);
    input = $(this);
    var prompt_id = this.selector + '_prompt';
    $('head:first').append("<link href='"+options.autocompleteCss+"' rel='stylesheet' type='text/css'/>").
      append("<link href='"+options.readlineCss+"' rel='stylesheet' type='text/css'/>");

    input.
      bind('keydown', 'ctrl+p', previous_line).
      bind('keydown', 'up', previous_line).
      bind('keydown', 'ctrl+n', next_line).
      bind('keydown', 'down', next_line).
      bind('keydown', 'ctrl+r', search_history).
      bind('keydown', 'ctrl+g', exit_search_history).
      bind('keydown', 'ctrl+u', clear_line).
      autocomplete(original_autocomplete_options).
      before('<span id="'+prompt_id.replace('#', '')+'"></span>');

    input_prompt = $(prompt_id);
    if (startCompletion = options.startCompletion) {
      input.bind('keydown', 'tab', tab_complete);
    }
    return this;
  };

  var addHistory = function(line) {
    readline_history.push(line);
    search_offset = readline_offset = 0;
  };
  var finishCompletion = function(completions) {
    var onclose = function() {
      input.autocomplete('option', original_autocomplete_options);
      $('ul.ui-autocomplete').hide();
    };
    if (completions.length == 1) {
      input.val(completions[0]);
      onclose();
    } else {
      input.autocomplete('option', { close: onclose, source: completions.sort() }).
        autocomplete('search');
    }
  };

  $.readline = {
    version: '0.1.0',
    addHistory: addHistory,
    finishCompletion: finishCompletion
  };
})(jQuery);
