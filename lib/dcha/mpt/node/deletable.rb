module Dcha
  module MPT
    class Node < Array
      # :nodoc:
      module Deletable
        def delete(key)
          case type
          when :blank then Node::BLANK
          when :branch then delete_branch_node(key)
          else
            delete_kv_node(key)
          end
        end

        private

        def delete_branch_node(key)
          if key.empty?
            self[-1] = Node::BLANK
            return normalize
          end

          new_sub_node = Node.decode(self[key[0]]).delete(key[1..-1])
          encoded_new_sub_node = new_sub_node.save
          return self if encoded_new_sub_node == self[key[0]]

          self[key[0]] = encoded_new_sub_node
          return normalize if encoded_new_sub_node == Node::BLANK

          self
        end

        def delete_kv_node(key)
          node_key = NibbleKey.decode(first).terminate(false)
          return self unless node_key.prefix?(key)
          return key == node_key ? Node::BLANK : self if type == :leaf

          new_sub_node = Node.decode(self[1]).delete(key[node_key.size..-1])

          replace_with_new_sub_node(node_key, new_sub_node)
        end

        def replace_with_new_sub_node(node_key, new_sub_node)
          return self if new_sub_node.save == self[1]
          return Node::BLANK if new_sub_node == Node::BLANK

          case new_sub_node.type
          when :branch
            Node.new([node_key.encode, new_sub_node.save])
          when :leaf, :extension
            new_key = node_key + NibbleKey.decode(new_sub_node[0])
            Node.new([new_key.encode, new_sub_node[1]])
          end
        end

        def normalize
          return self if non_blank_items.size > 1

          non_blank_index = non_blank_items[0][1]
          new_node = Node.new([NibbleKey.new([]).terminate(true).encode, last])
          return new_node if non_blank_index == NibbleKey::TERMINATOR

          replace_with_sub_node(non_blank_index)
        end

        def replace_with_sub_node(non_blank_index)
          sub_node = Node.decode(self[non_blank_index])
          case sub_node.type
          when :branch
            Node.new([NibbleKey.new([non_blank_index]).encode, sub_node.save])
          when :leaf, :extension
            new_key = NibbleKey.decode(sub_node[0]).unshift(non_blank_index)
            Node.new(new_key.encode, sub_node[1])
          end
        end

        def non_blank_items
          each_with_index.reject { |(x, _)| x == Node::BLANK }
        end
      end
    end
  end
end
