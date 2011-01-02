require 'ripl'
require 'ripl/web'
require 'nirvana/shell'
require 'nirvana/util'
require 'nirvana/runner'
require 'nirvana/version'

module Nirvana
  def self.start
    if Runner::EXIT_OPTIONS.include? ARGV[0]
      Nirvana::Runner.run ARGV
    else
      system %[nirvana-websocket #{ARGV.join(' ')} &]
      html_file = File.expand_path(File.dirname(__FILE__) + '/nirvana/public/index.html')
      RUBY_PLATFORM[/darwin/i]  ? system('open', html_file) : puts(html_file)
    end
  end
end
