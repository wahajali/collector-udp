require "socket"
require "pry"
require "eventmachine"
require "em-http-request"
require_relative "collector/config"
require_relative "collector/udphandler"
require_relative "collector/connection_pool"

module Udp
  module Collector
    class UDPCollector
      def start
        EM.run do
          EM.open_datagram_socket('0.0.0.0', ::Collector::Config.port, Udp::Collector::UDPHandler)
        end
      end
    end
  end
end
