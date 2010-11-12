module Ripl
  module Web
    def web_loop_once(input)
      @input = input || ''
    end

    def get_input
      @history << @input
      @input
    end
  end
end

Ripl::Shell.send :include, Ripl::Web
Ripl.config[:web] = true
