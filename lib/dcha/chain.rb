module Dcha
  # :nodoc:
  class Chain
    attr_reader :blocks

    def initialize
      @blocks = [Block::GENESIS]
    end

    def add_block(block)
      blocks << block if block.valid_after?(blocks.last)

      unless valid_chain?
        @blocks = @blocks[0..-2]
        return false
      end

      true
    end

    def create_and_add_block(root_hash)
      add_block(Block.new(
        index: blocks.last.index + 1,
        parent_hash: blocks.last.hash,
        root_hash: root_hash
      ).make_proof)
    end

    def replace_with(new_blocks)
      new_blocks = [Block::GENESIS] + new_blocks
      return unless valid_chain?(new_blocks) &&
                    new_blocks.length > blocks.length
      @blocks = new_blocks
      true
    end

    def valid_chain?(blocks = @blocks)
      valid = true
      blocks.each.with_index(0) do |block, idx|
        valid &&= if idx.zero?
                    Oj.dump(block) == Oj.dump(Block::GENSIS)
                  else
                    block.valid_after?(blocks[idx - 1])
                  end
      end
      valid
    end
  end
end
