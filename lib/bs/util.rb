require 'stringio'
require 'escape_utils'

module Bs
  module Util
    extend self

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
  end
end
