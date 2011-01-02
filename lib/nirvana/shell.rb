require 'json'
require 'ripl/completion'

module Nirvana
  # Included into Ripl::Shell at runtime
  module Shell
    def web_loop_once(input)
      super
      @eval_error = nil
      @input[/^:AUTOCOMPLETE:/] ? get_completions(@input) : loop_once
    rescue Exception => e
      exit if e.message[/^uncaught throw `ripl_exit'/]
      html_error(e, "Internal #{@name} error: ")
    end

    def print_result(result)
      @eval_error || format_result(@result)
    end

    def loop_eval(str)
      @stdout, @stderr, result = Util.capture_all { super(str) }
      result
    end

    def print_eval_error(error)
      @eval_error = html_error(error, '')
    end

    def format_result(result)
      stdout, stderr, output = Util.capture_all { super }
      @stdout << (stdout.empty? ? output : stdout)
      @stderr << stderr
      output = Util.format_output @stdout
      output = "<div class='nirvana_warning'>#{@stderr}</div>" + output unless @stderr.to_s.empty?
      output
    end

    protected
    def html_error(error, message)
      "<span class='nirvana_exception'>#{Util.format_output(message + format_error(error))}</span>"
    end

    def get_completions(input)
      arr = completions input.sub(/^:AUTOCOMPLETE:\s*/, '')
      ':AUTOCOMPLETE: ' + JSON.generate(arr)
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
