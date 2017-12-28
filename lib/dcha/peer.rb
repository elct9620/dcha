require 'dcha/peer/remote_executable'
require 'dcha/peer/can_heartbeat'

module Dcha
  # :nodoc:
  class Peer
    include RemoteExecutable
    include CanHeartbeat

    MULTICAST_ADDR = '224.5.5.55'.freeze
    BIND_ADDR = '0.0.0.0'.freeze
    PORT = '5555'.freeze

    attr_reader :hostname, :ipaddr

    def initialize
      @hostname = Socket.gethostname
      @ipaddr = Addrinfo.getaddrinfo(hostname, nil, :INET).first
      @peers = []
      @thread = nil
      @packets = PacketManager.new
    end

    def join
      return if listening?
      listen
      ping
    end

    def listening?
      @listening == true
    end

    def transmit(data)
      transmit_to MULTICAST_ADDR, data
    end

    def transmit_to(address, data)
      Chunk.split(data).each do |bytes|
        socket.send(bytes.pack('C*'), 0, address, PORT)
      end
    end

    private

    def listen
      socket.bind(BIND_ADDR, PORT)
      puts "Listen #{ipaddr.ip_address}:#{PORT} on #{hostname} "
      @thread = Thread.new { process }
      @listening = true
    end

    def process
      loop do
        resolve @packets.todo.pop(true) until @packets.todo.empty?
        receive
      end
    end

    def resolve(event)
      execute event[:action], event[:on], *event[:params]
    end

    def receive
      bytes, = socket.recvfrom(512)
      chunk = Chunk.new(bytes.unpack('C*'))
      @packets << chunk
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
