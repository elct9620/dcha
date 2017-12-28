module Dcha
  class Peer
    # :nodoc:
    module HasTrie
      def trie
        @trie ||= MPT::Trie.new
      end

      def reset(root_hash)
        @trie = MPT::Trie.new(root_hash)
      end

      def write(key, value)
        trie[key] = value
      end

      def read(key)
        trie[key]
      end
    end
  end
end
