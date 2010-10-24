require 'stringio'
require 'escape_utils'
require 'yajl'
require 'bs/shell'

module Bs
  extend self
  attr_accessor :shell

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
    stdout, stderr = capture_all { @shell = Shell.new :name=>'bs' }
    ws.send(format_output(stdout.to_s + stderr.to_s)) unless (stdout.to_s + stderr.to_s).empty?
  end

  def get_completions(msg)
    completions = shell.completions msg.sub(/^:AUTOCOMPLETE:\s*/, '')
    ':AUTOCOMPLETE: ' + Yajl::Encoder.encode(completions)
  end

  def get_eval_result(msg)
    begin
      stdout, stderr, result = capture_all do
        shell.eval_line msg
      end
    rescue Exception => e
      return format_error(e)
    end

    response = stdout << shell.after_eval(result)
    output = format_output response
    output = "<div class='bs_warning'>#{stderr}</div>" + output unless stderr.to_s.empty?
    output
  end

  def format_error(error, message='')
    message << error.to_s << "\n" << error.backtrace.map { |l| "\t#{l}" }.join("\n")
    "<span class='bs_exception'>#{format_output(message)}</span>"
  end

  def eval_line(msg)
    shell.has_autocompletion && msg[/^:AUTOCOMPLETE:/] ?
      get_completions(msg) : get_eval_result(msg)
  rescue Exception => e
    format_error(e, "Internal bs error: ")
  end

  def start
    system "bs-websocket &"
    html_file = File.expand_path(File.dirname(__FILE__) + '/bs/public/index.html')
    RUBY_PLATFORM[/darwin/i]  ? system('open', html_file) : puts(html_file)
  end
end
