require 'em-websocket'
require 'stringio'
require 'escape_utils'
require 'yajl'

module Brirb
  extend self
  attr_reader :has_autocompletion
  attr_accessor :line, :brirb_binding
  @line = 1

  def capture_stdout
    out = StringIO.new
    $stdout = out
    yield
    return out.string
  ensure
    $stdout = STDOUT
  end

  def capture_stderr
    out = StringIO.new
    $stderr = out
    yield
    return out.string
  ensure
    $stderr = STDERR
  end

  def capture_all
    stdout, stderr, result = nil
    stderr = capture_stderr do
      stdout = capture_stdout do
        result = yield
      end
    end
    [stdout, stderr, result]
  end

  def format_output(response)
    EscapeUtils.escape_html(response).gsub("\n", "<br>").gsub("\t", "    ").gsub(" ", "&nbsp;")
  end

  def setup_repl(ws)
    ws.send RUBY_DESCRIPTION rescue RUBY_VERSION
    if File.exists?(File.expand_path('~/.irbrc'))
      stdout, stderr = capture_all { load('~/.irbrc') }
      ws.send format_output(stdout + stderr)
    end

    begin
      require 'bond'
      Bond.start
      @has_autocompletion = true
    rescue LoadError
      @has_autocompletion = false
    end
  end

  def get_completions(msg)
    line_buffer = msg.sub(/^:AUTOCOMPLETE:\s*/, '')
    msg = "Bond.agent.call('#{line_buffer[/\w+$/]}', '#{line_buffer}')"
    completions = eval(msg, brirb_binding, '(brirb)')
    ':AUTOCOMPLETE: ' + Yajl::Encoder.encode(completions)
  end

  def get_eval_result(msg)
    begin
      stdout, stderr, result = capture_all do
        eval(msg, brirb_binding, '(brirb)', line)
      end
    rescue Exception => e
      return format_error(e)
    end

    eval("_ = #{result.inspect}", brirb_binding) rescue nil
    self.line += 1
    response = stdout << "=> #{result.inspect}"
    output = format_output response
    output = "<div class='warning'>#{stderr}</div>" + output unless stderr.to_s.empty?
    output
  end

  def format_error(error, message='')
    message << error.to_s << "\n" << error.backtrace.map { |l| "\t#{l}" }.join("\n")
    "<span class='exception'>#{format_output(message)}</span>"
  end

  def eval_line(msg)
    has_autocompletion && msg[/^:AUTOCOMPLETE:/] ?
      get_completions(msg) : get_eval_result(msg)
  rescue Exception => e
    format_error(e, "Internal brirb error: ")
  end
end

EventMachine.run do
  EventMachine::WebSocket.start(:host => '127.0.0.1', :port => 8080) do |ws|
    Brirb.brirb_binding = binding
    ws.onopen { Brirb.setup_repl(ws) }
    ws.onmessage {|msg| ws.send Brirb.eval_line(msg) }
  end
end
