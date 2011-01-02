module Nirvana
  class Runner < Ripl::Runner
    self.app = 'nirvana'
    EXIT_OPTIONS = %w{-h --help -v --version}

    def self.run_command(argv)
      begin
        cmd = argv.shift
        require "ripl/#{cmd}"
      rescue LoadError
        abort "`#{cmd}' is not a nirvana command."
      end
      start
    end

    def self.start(options={})
      @argv = options[:argv]
      parse_options @argv.dup
      stdout, stderr = Util.capture_all {
        load_rc(Ripl.config[:riplrc]) unless @argv.include? '-F'
        Ripl::Shell.include Nirvana::Shell
        (Ripl.config[:hirb] ||= {})[:pager] = false if defined? Hirb
        Ripl.shell(:name=>'nirvana', :readline=>false).before_loop
      }
      (result = stdout.to_s + stderr.to_s) ? Util.format_output(result) : result
    end
  end
end
