require 'dcha/ui/window'

module Dcha
  # TODO: Implement `curses` ui
  # :nodoc:
  class UI
    include Curses

    def initialize(peer)
      @window = Window.new(0, 0, 0, 0)
      @peer = peer
      @input = ''
    end

    def show
      until @input == 'exit'
        parse
        @window.update do
          show_peers
        end
        @input = @window.getstr
      end
      @window.close
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

    def show_peers
      message = "Peers: #{@peer.peers.size} >"
      offset = message.size + 2
      @window.setpos(@window.maxy - 2, offset)
      @window.heading = message
      @window.peers = @peer.peers
    end
  end
end
