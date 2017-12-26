module Dcha
  module MPT
    class Node < Array
      # :nodoc:
      module Findable
        def find(nbk)
          case type
          when :blank then Node::BLANK.first
          when :branch then find_branch(nbk)
          when :leaf then find_leaf(nbk)
          when :extension then find_extension(nbk)
          end
        end

        private

        def find_branch(nbk)
          return last if nbk.empty?
          node = Node.decode(self[nbk[0]])
          node.find(nbk[1..-1])
        end

        def find_leaf(nbk)
          key = NibbleKey.decode(first).terminate(false)
          nbk == key ? self[1] : Node::BLANK.first
        end

        def find_extension(nbk)
          key = NibbleKey.decode(first).terminate(false)
          return Node::BLANK.first unless key.prefix?(nbk)
          node = Node.decode(self[1])
          node.find nbk[key.size..-1]
        end
      end
    end
  end
end
