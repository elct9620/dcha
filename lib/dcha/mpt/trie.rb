module Dcha
  module MPT
    # :nodoc:
    class Trie
      include Enumerable

      def initialize(hash = nil)
        @root = if hash.nil?
                  Node::BLANK
                else
                  Node.decode(hash)
                end
      end

      def root_hash
        return blank_root if @root == Node::BLANK
        @root.save(true)
      end
      alias update_root_hash root_hash

      def get(key)
        @root.find NibbleKey.from_string(key)
      end
      alias [] get

      def set(key, value)
        @root = @root.update(
          NibbleKey.from_string(key),
          value
        )

        update_root_hash
      end
      alias []= set

      def delete(key)
        @root = @root.delete(NibbleKey.from_string(key))

        update_root_hash
      end

      def to_h
        Hash[
          @root.to_h.map do |key, value|
            [
              key.terminate(false).to_s,
              value
            ]
          end
        ]
      end

      def each(&block)
        to_h.each(&block)
      end

      def key?(key)
        self[key] != Node::BLANK.first
      end
      alias include? key?

      def size
        @root.tree_size
      end

      private

      def blank_root
        @blank_root ||= Config.digest.hexdigest(RLP.encode('')).freeze
      end
    end
  end
end
