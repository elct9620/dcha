module Dcha
  class Peer
    # :nodoc:
    module CanHeartbeat
      def ping
        transmit action: :pong, params: [ipaddr.ip_address]
      end

      def pong(address)
        transmit action: :mine, params: [chain.blocks]
        transmit_to address, action: :add_peer, params: [ipaddr.ip_address]
      end

      def add_peer(address)
        @peers.push(address).uniq!
      end
    end
  end
end
