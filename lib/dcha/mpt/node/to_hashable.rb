module Dcha
  module MPT
    class Node < Array
      # :nodoc:
      module ToHashable
        def to_h
          case type
          when :blank then {}
          when :branch then branch_to_h
          when :leaf, :extension
            kv_to_h
          end
        end

        private

        def branch_to_h
          hash = {}
          16.times do |i|
            sub_hash = Node.decode(self[i]).to_h
            sub_hash.each { |k, v| hash[NibbleKey.new([i]) + k] = v }
          end
          hash[NibbleKey.terminator] = last if last
          hash
        end

        def kv_to_h
          nibbles = NibbleKey.decode(first).terminate(false)
          sub_hash = if type == :extension
                       Node.decode(self[1]).to_h
                     else
                       { NibbleKey.terminator => self[1] }
                     end

          {}.tap do |h|
            sub_hash.each { |k, v| h[nibbles + k] = v }
          end
        end
      end
    end
  end
end
