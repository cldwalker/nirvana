require 'yajl'
require 'ripl/completion'

module Bs
  class Shell < Ripl::Shell

    def loop_once(input)
      @eval_error = nil
      if input[/^:AUTOCOMPLETE:/]
        get_completions(input)
      else
        super
        @eval_error || format_result(@last_result)
      end
    rescue Exception => e
      html_error(e, "Internal #{@name} error: ")
    end

    def loop_eval(str)
      @stdout, @stderr, result = Util.capture_all { super(str) }
      result
    end

    def print_eval_error(error)
      @eval_error = html_error(error, '')
    end

    def format_result(result)
      output = Util.format_output @stdout + super
      output = "<div class='bs_warning'>#{@stderr}</div>" + output unless @stderr.to_s.empty?
      output
    end

    protected
    def html_error(error, message)
      "<span class='bs_exception'>#{Util.format_output(message + format_error(error))}</span>"
    end

    def get_completions(input)
      arr = completions input.sub(/^:AUTOCOMPLETE:\s*/, '')
      ':AUTOCOMPLETE: ' + Yajl::Encoder.encode(arr)
    end

    def completions(line_buffer)
      msg = "Bond.agent.call('#{line_buffer[/\w+$/]}', '#{line_buffer}')"
      eval(msg, @binding, "(#{@name})") rescue []
    end

  end
end
