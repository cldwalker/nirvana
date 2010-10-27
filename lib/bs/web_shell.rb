module Bs
  class WebShell < Shell
    def loop_once(input)
      has_autocompletion && input[/^:AUTOCOMPLETE:/] ?
        get_completions(input) : super
    rescue Exception => e
      Bs.format_error(e, "Internal #{@name} error: ")
    end

    def get_completions(input)
      arr = completions input.sub(/^:AUTOCOMPLETE:\s*/, '')
      ':AUTOCOMPLETE: ' + Yajl::Encoder.encode(arr)
    end

    def eval_line(str)
      @stdout, @stderr, result = Bs.capture_all { super(str) }
      result
    end

    def print_eval_error(e)
      Bs.format_error(e)
    end

    def format_result(result)
      output = Bs.format_output @stdout + super
      output = "<div class='bs_warning'>#{@stderr}</div>" + output unless @stderr.to_s.empty?
      output
    end
  end
end
