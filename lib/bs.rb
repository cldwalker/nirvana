require 'ripl'
require 'ripl/web'
require 'bs/shell'
require 'bs/util'

module Bs
  def self.start_shell
    stdout, stderr = Util.capture_all { Ripl.shell(:name=>'bs', :readline=>false).before_loop }
    (result = stdout.to_s + stderr.to_s) ? Util.format_output(result) : result
  end

  def self.start
    system "bs-websocket &"
    html_file = File.expand_path(File.dirname(__FILE__) + '/bs/public/index.html')
    RUBY_PLATFORM[/darwin/i]  ? system('open', html_file) : puts(html_file)
  end
end
