require 'em-websocket'
require 'bs'

module Bs
  module Websocket
    def self.run
      EventMachine.run do
        EventMachine::WebSocket.start(:host => '127.0.0.1', :port => 8080) do |ws|
          Bs.eval_binding = binding
          ws.onopen { Bs.setup_repl(ws) }
          ws.onmessage {|msg| ws.send Bs.eval_line(msg) }
        end
      end
    rescue
      message = "Unable to start websocket since port 8080 is occupied"
      message = $!.message unless $!.message[/no acceptor/]
      abort "bs websocket error: #{message}"
    end
  end
end
