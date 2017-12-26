module Dcha
  module MPT
    # :nodoc:
    class Node < Array
      autoload :Findable, 'dcha/mpt/node/findable'
      autoload :Editable, 'dcha/mpt/node/editable'
      autoload :Deletable, 'dcha/mpt/node/deletable'
      autoload :ToHashable, 'dcha/mpt/node/to_hashable'

      class << self
        def decode(encoded)
          return BLANK if encoded == BLANK.first
          return encoded if encoded.is_a?(Node)
          return new encoded if encoded.is_a?(Array)
          new RLP.decode(Config.store[encoded])
        end
      end

      BLANK = new(['']).freeze

      BRANCH_CARDINAL = 16
      BRANCH_WIDTH = BRANCH_CARDINAL + 1
      KV_WIDTH = 2

      include Node::Findable
      include Node::Editable
      include Node::Deletable
      include Node::ToHashable

      def type
        return :blank if size == 1 && first.empty?

        case size
        when KV_WIDTH
          NibbleKey.decode(first).terminate? ? :leaf : :extension
        when BRANCH_WIDTH
          :branch
        end
      end

      def tree_size
        case type
        when :branch
          children = take(BRANCH_CARDINAL).map(&:tree_size)
          children.push(last != BLANK ? 0 : 1)
          size.reduce(0, &:+)
        when :extension then Node.decode(self[1]).tree_size
        when :leaf then 1
        when :blank then 0
        end
      end

      def save(force = false)
        value = RLP.encode self
        return self if value.size < 32 && !force
        key = Config.digest.hexdigest(value)

        Config.store[key] = value

        key
      end
    end
  end
end
