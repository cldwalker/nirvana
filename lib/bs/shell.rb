require 'yajl'

module Bs
  class Shell < Ripl::Shell
    def loop_once(input)
      @eval_error = nil
      has_autocompletion && input[/^:AUTOCOMPLETE:/] ?
        get_completions(input) : super
    rescue Exception => e
      format_error(e, "Internal #{@name} error: ")
    end

    def get_completions(input)
      arr = completions input.sub(/^:AUTOCOMPLETE:\s*/, '')
      ':AUTOCOMPLETE: ' + Yajl::Encoder.encode(arr)
    end

    def completions(line_buffer)
      msg = "Bond.agent.call('#{line_buffer[/\w+$/]}', '#{line_buffer}')"
      eval(msg, @binding, "(#{@name})") rescue []
    end

    def eval_line(str)
      @stdout, @stderr, result = Util.capture_all { super(str) }
      result
    end

    def format_error(error, message)
      message << error.to_s << "\n" << error.backtrace.map { |l| "\t#{l}" }.join("\n")
      "<span class='bs_exception'>#{Util.format_output(message)}</span>"
    end

    def print_eval_error(error)
      @eval_error = format_error(error, '')
    end

    def format_result(result)
      return @eval_error if @eval_error
      output = Util.format_output @stdout + super
      output = "<div class='bs_warning'>#{@stderr}</div>" + output unless @stderr.to_s.empty?
      output
    end
  end
end
