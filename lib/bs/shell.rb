require 'yajl'
require 'ripl/completion'

module Bs
  module Shell
    def loop_once(input)
      @history << input
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
      input = line_buffer[/([^#{Bond::Readline::DefaultBreakCharacters}]+)$/,1]
      arr = Bond.agent.call(input || line_buffer, line_buffer)
      return [] if arr[0].to_s[/^Bond Error:/] #silence bond debug errors
      return arr if input == line_buffer
      chopped_input = line_buffer.sub(/#{Regexp.quote(input.to_s)}$/, '')
      arr.map {|e| chopped_input + e }
    end
  end
end

Ripl::Shell.send :include, Bs::Shell
