require 'em-websocket'
require 'bs'

module Bs
  module Websocket
    def self.run
      EventMachine.run do
        EventMachine::WebSocket.start(:host => '127.0.0.1', :port => 8080) do |ws|
          ws.onopen {
            result = Bs.start_shell
            ws.send(result) unless result.to_s.empty?
          }
          ws.onmessage {|msg| ws.send Bs.shell.loop_once(msg) }
        end
      end
    rescue
      message = "Unable to start websocket since port 8080 is occupied"
      message = $!.message unless $!.message[/no acceptor/]
      abort "bs websocket error: #{message}"
    end
  end
end
