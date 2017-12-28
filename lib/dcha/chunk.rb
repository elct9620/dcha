module Dcha
  # :nodoc:
  class Chunk < Array
    SIZE = 128
    TAG_SIZE = 40 # SHA1

    class << self
      def create(data)
        split(data).map { |bytes| new bytes }
      end

      def split(data)
        buffer = Oj.dump(data)
        tag = Digest::SHA1.hexdigest(buffer).unpack('C*')
        slices = buffer.unpack('C*').each_slice(SIZE)
        size = slices.size
        slices.map.with_index do |bytes, index|
          [tag, index, size, bytes].flatten
        end
      end
    end

    include Comparable

    attr_reader :tag, :index, :total

    def initialize(bytes)
      super
      @tag = bytes.shift(TAG_SIZE).pack('C*')
      @index = bytes.shift
      @total = bytes.shift
      @buffer = bytes.pack('C*')
    end

    def <=>(other)
      index <=> other.index
    end

    def to_s
      @buffer
    end
  end
end
