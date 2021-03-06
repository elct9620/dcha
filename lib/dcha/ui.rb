require 'dcha/ui/window'

module Dcha
  # TODO: Implement `curses` ui
  # :nodoc:
  class UI
    include Curses

    def initialize(peer)
      @window = Window.new(0, 0, 0, 0)
      @peer = peer
      @logs = []
      @input = ''
      @peer.add_observer(self)
    end

    def show
      until @input == 'exit'
        parse
        refresh
        @input = @window.getstr
      end
      @window.close
    end

    def update(action, _, _params, time)
      @logs.push("Execute #{action} at #{time}")
      refresh
    end

    private

    def refresh
      @window.update do
        show_logs
        show_peers
      end
    end

    def read
      key = @input.split(' ').last
      @logs.push "#{key} -> #{@peer.read(key)}"
    end

    def write
      _, key, value = @input.split(' ')
      @peer.write(key, value)
      @peer.create_block(@peer.trie.root_hash)
    end

    def chain
      @logs.push "CHAIN BLOCKS: #{@peer.chain.blocks.size}"
    end

    def root
      @logs.push "TRIE ROOT: #{@peer.trie.root_hash}"
    end

    def parse
      return if @input.empty?
      return read if @input.start_with?('GET')
      return write if @input.start_with?('SET')
      return chain if @input.start_with?('CHAIN')
      return root if @input.start_with?('ROOT')
    end

    def show_peers
      message = "Peers: #{@peer.peers.size} >"
      offset = message.size + 2
      @window.setpos(@window.maxy - 2, offset)
      @window.heading = message
      @window.peers = @peer.peers
    end

    def show_logs
      max_log = @window.maxy - 5
      start_pos = @window.maxx * 0.3 + 2
      @logs.last(max_log).each.with_index do |log, index|
        @window.setpos(index + 1, start_pos)
        @window.addstr(log)
      end
    end
  end
end
