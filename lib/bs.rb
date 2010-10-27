require 'bs/shell'
require 'bs/web_shell'
require 'bs/util'

module Bs
  extend self
  attr_accessor :shell

  def start_shell(ws)
    stdout, stderr = Util.capture_all { @shell = WebShell.new :name=>'bs' }
    ws.send(Util.format_output(stdout.to_s + stderr.to_s)) unless (stdout.to_s + stderr.to_s).empty?
  end

  def start
    system "bs-websocket &"
    html_file = File.expand_path(File.dirname(__FILE__) + '/bs/public/index.html')
    RUBY_PLATFORM[/darwin/i]  ? system('open', html_file) : puts(html_file)
  end
end
