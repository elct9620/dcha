module Dcha
  class Peer
    # :nodoc:
    module HasTrie
      def trie
        @retry = false
        @trie ||= MPT::Trie.new
      end

      def reset(root_hash)
        return if root_hash == trie.root_hash
        @trie = MPT::Trie.new(root_hash)
      rescue Store::DataUnavailableError => e
        transmit action: :store_get, params: [
          root_hash,
          e.message,
          ipaddr.ip_address
        ]
      end

      def store_get(root_hash, key, _address)
        return if root_hash != trie.root_hash
        changed
        transmit action: :store_set, params: [
          root_hash,
          key,
          Config.store[key]
        ]
      rescue Store::DataUnavailableError
        nil
      end

      def store_set(root_hash, key, value)
        Config.store[key] = value
        reset(root_hash) if root_hash != trie.root_hash
      end

      def write(key, value)
        trie[key] = value
      end

      def read(key)
        trie[key]
      rescue Store::DataUnavailableError => e
        transmit action: :store_get, params: [
          trie.root_hash,
          e.message,
          ipaddr.ip_address
        ]
        '[SYNCING]'
      end
    end
  end
end
