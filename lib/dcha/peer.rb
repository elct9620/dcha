module Dcha
  # :nodoc:
  class Peer
    MULTICAST_ADDR = '224.5.5.55'.freeze
    BIND_ADDR = '0.0.0.0'.freeze
    PORT = '5555'.freeze

    attr_reader :hostname, :ipaddr

    def initialize
      @hostname = Socket.gethostname
      @ipaddr = Addrinfo.getaddrinfo(hostname, nil, :INET).first
      @peers = []
      @thread = nil
    end

    def join
      return if listening?
      listen
    end

    def listening?
      @listening == true
    end

    private

    def listen
      socket.bind(BIND_ADDR, PORT)
      puts "Listen #{ipaddr.ip_address}:#{PORT} on #{hostname} "
      @thread = Thread.new { loop { receive } }
      @listening = true
    end

    def receive
      # TODO
    end

    def socket
      @socket ||= UDPSocket.open.tap do |socket|
        socket.setsockopt(:IPPROTO_IP, :IP_ADD_MEMBERSHIP, bind_address)
        socket.setsockopt(:IPPROTO_IP, :IP_MULTICAST_TTL, 1)
        socket.setsockopt(:SOL_SOCKET, :SO_REUSEPORT, 1)
      end
    end

    def bind_address
      IPAddr.new(MULTICAST_ADDR).hton + IPAddr.new(BIND_ADDR).hton
    end
  end
end
