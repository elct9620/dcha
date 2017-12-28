module Dcha
  # :nodoc:
  class PacketManager < Hash
    attr_reader :todo

    def initialize
      @todo = Queue.new
    end

    def <<(chunk)
      self[chunk.tag] ||= []
      self[chunk.tag] << chunk
      self[chunk.tag].uniq!

      check(chunk)
    end

    private

    def check(chunk)
      return unless self[chunk.tag].size == chunk.total
      event = Oj.load(self[chunk.tag].sort.map(&:to_s).join)
      @todo << event
      # TODO: Release memory if buffer not completed
      delete(chunk.tag)
    end
  end
end
