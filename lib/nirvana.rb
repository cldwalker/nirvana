require 'ripl'
require 'ripl/web'
require 'nirvana/shell'
require 'nirvana/util'
require 'nirvana/version'

module Nirvana
  def self.start_shell
    stdout, stderr = Util.capture_all {
      Ripl::Runner.load_rc(Ripl.config[:riplrc])
      (Ripl.config[:hirb] ||= {})[:pager] = false
      Ripl::Shell.include Nirvana::Shell
      Ripl.shell(:name=>'nirvana', :readline=>false).before_loop
    }
    (result = stdout.to_s + stderr.to_s) ? Util.format_output(result) : result
  end

  def self.start
    system "nirvana-websocket &"
    html_file = File.expand_path(File.dirname(__FILE__) + '/nirvana/public/index.html')
    RUBY_PLATFORM[/darwin/i]  ? system('open', html_file) : puts(html_file)
  end
end
