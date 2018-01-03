module Dcha
  class Peer
    # :nodoc:
    module CanHeartbeat
      def ping
        transmit action: :pong, params: [ipaddr.ip_address]
      end

      def pong(address)
        return if @peers.include?(address)
        transmit action: :mine, params: [chain.blocks]
        @peers.push(address).uniq!
        transmit_to address, action: :pong, params: [ipaddr.ip_address]
      end
    end
  end
end
