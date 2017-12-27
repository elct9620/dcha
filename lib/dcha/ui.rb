module Dcha
  # TODO: Implement `curses` ui
  # :nodoc:
  class UI
    include Singleton

    def initialize
      @input = ''
    end

    def show
      until @input == 'exit'
        print '> '
        @input = STDIN.gets.chomp
      end
    end
  end
end
