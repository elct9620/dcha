module Dcha
  # TODO: Implement `curses` ui
  # :nodoc:
  class UI
    def initialize(peer)
      @peer = peer
      @input = ''
    end

    def show
      until @input == 'exit'
        parse
        print "(PEERS: #{@peer.peers.size}) > "
        @input = STDIN.gets.chomp
      end
    end

    private

    def read
      key = @input.split(' ').last
      puts "#{key} IS: #{@peer.read(key)}"
    end

    def write
      _, key, value = @input.split(' ')
      @peer.transmit action: :write, params: [key, value]
    end

    def parse
      return if @input.empty?
      return read if @input.start_with?('GET')
      return write if @input.start_with?('SET')
    end
  end
end
