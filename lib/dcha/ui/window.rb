module Dcha
  class UI
    # :nodoc:
    class Window < Curses::Window
      def initialize(*)
        super

        @sidebar = subwin(maxy - 2, maxx * 0.3, 0, 0)
        @input = subwin(3, 0, maxy - 3, 0)
      end

      def update(&_block)
        clear
        update_sidebar
        box('|', '-')
        update_input
        yield if block_given?
        refresh
      end

      def heading=(head)
        @input.setpos(1, 1)
        @input.addstr(head)
      end

      # TODO: Cut off string if overflow
      def peers=(peers)
        peers = peers.take(maxy - 5)
        peers.push('And more ...') if peers.size == maxy - 5
        peers.each.with_index do |peer, index|
          @sidebar.setpos(index + 1, 2)
          @sidebar.addstr(peer)
        end
      end

      private

      def update_sidebar
        @sidebar.clear
        @sidebar.resize(maxy - 2, maxx * 0.3)
        @sidebar.box('|', '-')
      end

      # TODO: Fix position incorrect after resize
      def update_input
        @input.clear
        @input.move(maxy - 3, 0)
        @input.box('|', '-')
      end
    end
  end
end
