module Dcha
  class Peer
    # :nodoc:
    module CanHeartbeat
      def ping
        transmit action: :pong, params: []
      end

      def pong
        transmit action: :add_peer, params: [ipaddr.ip_address]
      end

      def add_peer(address)
        @peers.push(address).uniq!
      end
    end
  end
end
