(function($) {
  var screen, input, spinner_id;
  var spinner = "<div id='%s' style='background: url(spinner.gif) no-repeat 0 center; "+
    "vertical-align: middle;'> &nbsp;</div>";

  $.fn.repl = function(options) {
    options = $.extend({
      screen: '#screen',
      prompt: '&gt;&gt; ',
      eval: function(val) {},
      keys: true
    }, options);
    input = $(this);
    screen = $(options.screen);
    spinner_id = (this.selector + '_spinner').replace('#', '');
    spinner = spinner.replace('%s', spinner_id);

    var prompt_id = (this.selector + '_prompt').replace('#', '');
    if (!$(prompt_id).length) {
      input.before('<span id="'+prompt_id+'"></span>');
    }
    $('#'+prompt_id).html(options.prompt);

    input.focus();
    input.parent('form').submit(function() {
      var value = input.val();
      $.repl.log(options.prompt + value + spinner);
      options.eval(value);
      input.val("").focus();
      return false;
    });
    if (options.keys) {
      input.bind('keydown', 'ctrl+l', function() { screen.html(''); });
    }
    return this;
  };

  $.repl = {
    version: '0.1.0',
    log: function(str) {
      screen.append("" + (str) + "<br>");
      return $('body').scrollTop($('body').attr('scrollHeight'));
    },
    logResult: function(str) {
      $('#'+spinner_id).remove();
      $.repl.log(str);
    }
  };
})(jQuery);
