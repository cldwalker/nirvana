module Bs
  class Shell
    OPTIONS = {:name=>'shell', :line=>1, :result_prompt=>'=> ',
      :binding=>TOPLEVEL_BINDING, :irbrc=>'~/.irbrc'}

    attr_accessor :line, :binding, :result_prompt
    attr_reader :has_autocompletion
    def initialize(options={})
      @options = OPTIONS.merge options
      @name, @binding, @line = @options.values_at(:name, :binding, :line)
      start_completion
      load_rc
    end

    def start_completion
      require 'bond'
      Bond.start
      @has_autocompletion = true
    rescue LoadError
      @has_autocompletion = false
    end

    def load_rc
      load @options[:irbrc] if File.exists?(File.expand_path(@options[:irbrc]))
    end

    def eval_line(str)
      eval(str, @binding, "(#{@name})", @line)
    end

    def after_eval(result)
      eval("_ = #{result.inspect}", @binding) rescue nil
      @line += 1
      @options[:result_prompt] + result.inspect
    end

    def completions(line_buffer)
      msg = "Bond.agent.call('#{line_buffer[/\w+$/]}', '#{line_buffer}')"
      eval(msg, @binding, "(#{@name})") rescue []
    end
  end
end
