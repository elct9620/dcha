module Dcha
  class Peer
    # :nodoc:
    module CanHeartbeat
      def ping
        transmit action: :pong, params: [ipaddr.ip_address]
      end

      def pong(address)
        @peers.push(address).uniq!
        return if ipaddr.ip_address == address
        transmit_to address, action: :pong, params: [ipaddr.ip_address]
      end
    end
  end
end
