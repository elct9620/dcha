# rubocop:disable Metrics/LineLength
module Dcha
  module MPT
    class Node < Array
      # :nodoc:
      module Editable
        def update(key, value)
          case type
          when :blank then
            dup.clear.push key.terminate(true).encode, value
          when :branch then update_branch(key, value)
          when :leaf then update_leaf(key, value)
          else update_extension(key, value)
          end
        end

        private

        def update_branch(key, value)
          return dup.tap { |copy| copy[-1] = value } if key.empty?

          new_node = Node.decode(self[key[0]])
                         .update(key[1..-1], value)
          dup.tap do |copy|
            copy[key[0]] = new_node
          end
        end

        def update_leaf(key, value)
          node_key, common_key, remain_key, remain_node_key = common_key_pairs(key)

          no_remain_key = remain_key.empty? && remain_node_key.empty?
          return dup.clear.push first, value if no_remain_key

          new_node = if remain_node_key.empty?
                       convert_leaf_to_branch_node(remain_key, value)
                     else
                       expand_leaf_to_branch_node(remain_key, remain_node_key, value)
                     end

          apply_node(common_key, node_key, new_node)
        end

        def apply_node(common_key, node_key, new_node)
          if common_key.empty?
            dup.clear.concat new_node
          else
            dup.clear.push node_key[0, common_key.size].encode,
                           Node.new(new_node).save
          end
        end

        def convert_leaf_to_branch_node(key, value)
          new_node = Node::BLANK * Node::BRANCH_WIDTH
          new_node[-1] = self[1]

          new_node[key[0]] = Node.new(
            [
              key[1..-1].terminate(true).encode,
              value
            ]
          ).save
          new_node
        end

        def expand_leaf_to_branch_node(key, node_key, value)
          new_node = convert_leaf_to_branch_node(node_key, self[1])

          if key.empty?
            new_node[-1] = value
          else
            new_node[key[0]] = Node.new(
              [key[1..-1].terminate(true).encode, value]
            ).save
          end

          new_node
        end

        def update_extension(key, value)
          node_key, common_key, remain_key, remain_node_key = common_key_pairs(key)

          new_node = if remain_node_key.empty?
                       Node.decode(self[1]).update(remain_key, value)
                     else
                       expand_extension_to_branch_node(
                         remain_key, remain_node_key, value
                       )
                     end
          apply_node(common_key, node_key, new_node)
        end

        def convert_extension_to_branch_node(key, value)
          new_node = Node::BLANK * Node::BRANCH_WIDTH

          if key.size == 1
            new_node[key[0]] = value
            return new_node
          end

          new_node[key[0]] = Node.new(
            [key[1..-1].terminate(false).encode, value]
          ).save

          new_node
        end

        def expand_extension_to_branch_node(key, node_key, value)
          new_node = convert_extension_to_branch_node(node_key, self[1])

          if key.empty?
            new_node[-1] = value
            return new_node
          end

          new_node[key[0]] = Node.new(
            [key[1..-1].terminate(true).encode, value]
          ).save

          new_node
        end

        def common_key_pairs(key)
          node_key = NibbleKey.decode(first).terminate(false)

          common = node_key.common_prefix(key)
          remain = key[common.size..-1]
          remain_node = node_key[common.size..-1]

          [node_key, common, remain, remain_node]
        end
      end
    end
  end
end
