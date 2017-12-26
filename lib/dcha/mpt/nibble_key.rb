module Dcha
  module MPT
    # :nodoc:
    class NibbleKey < Array
      TERM_FLAG  = 0b0010
      ODD_FLAG   = 0b0001
      TERMINATOR = 16

      HEX_VALUES = Hash[(0..15).map { |i| [i.to_s(16), i] }]

      class << self
        def encode(nibbles)
          flags = 0

          if nibbles.last == TERMINATOR
            flags |= TERM_FLAG
            nibbles = nibbles[0...-1]
          end

          odd = nibbles.size % 2
          flags |= odd
          return pack [flags] + nibbles if odd == 1
          pack [flags, 0b0000] + nibbles
        end

        def decode(bytes)
          o = from_string bytes
          flags = o[0]

          o.push TERMINATOR if flags & TERM_FLAG > 0
          fill = flags & ODD_FLAG > 0 ? 1 : 2
          new o[fill..-1]
        end

        def from_string(s)
          nibbles = s.unpack('H*')
                     .first
                     .each_char
                     .map { |c| HEX_VALUES[c] }
          new nibbles
        end

        def to_string(nibbles)
          # TODO: Add error message
          raise ArgumentError unless nibbles.any? { |x| x.between?(0, 15) }
          raise ArgumentError if nibbles.size.odd?

          pack nibbles
        end

        def terminator
          new [TERMINATOR]
        end

        private

        def pack(nibbles)
          size = nibbles.size / 2
          (0...size).map do |i|
            base = i * 2
            (16 * nibbles[base] + nibbles[base + 1]).chr
          end.join
        end
      end

      def terminate?
        last == TERMINATOR
      end

      def terminate(flag)
        dup.tap do |copy|
          if flag
            copy.push TERMINATOR unless copy.terminate?
          elsif copy.terminate?
            copy.pop
          end
        end
      end

      def prefix?(another_key)
        return false if another_key.size < size
        another_key.take(size) == self
      end

      def common_prefix(another_key)
        prefix = []

        [size, another_key.size].min.times do |i|
          break if self[i] != another_key[i]
          prefix.push self[i]
        end

        self.class.new prefix
      end

      def encode
        self.class.encode self
      end

      def to_s
        self.class.to_string self
      end
      alias to_string to_s

      def +(other)
        self.class.new super(other)
      end
    end
  end
end
