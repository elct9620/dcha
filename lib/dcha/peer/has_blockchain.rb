module Dcha
  class Peer
    # :nodoc:
    module HasBlockchain
      def chain
        @chain ||= Chain.new
      end

      def blocks(_address)
        transmit action: :mine, params: [chain.blocks]
      end

      def mine(blocks)
        blocks.sort! { |x, y| x.index <=> y.index }
        return unless blocks.last.index > chain.blocks.last.index
        append_blocks(blocks)
      end

      def create_block(root_hash)
        return unless chain.create_and_add_block(root_hash)
        transmit action: :mine, params: [chain.blocks.last(1)]
      end

      private

      def append_blocks(blocks)
        if block_linked?(blocks)
          add_block(blocks)
        elsif blocks.length == 1
          ask_blocks
        elsif blocks.length > 1
          replace_blocks(blocks)
        end
      end

      def add_block(blocks)
        return unless blocks.last.valid_proof?
        chain.add_block(blocks.last)
        reset(blocks.last.root_hash)
        transmit action: :mine, params: [blocks.last(1)]
      end

      def ask_blocks
        transmit action: :blocks, params: [ipaddr.ip_address]
      end

      def replace_blocks(blocks)
        blocks.shift if blocks.first.index.zero?
        chain.replace_with(blocks)
        reset(blocks.last.root_hash)
        transmit action: :mine, params: [blocks.last(1)]
      end

      def block_linked?(blocks)
        blocks.last.parent_hash == chain.blocks.last.hash
      end
    end
  end
end
