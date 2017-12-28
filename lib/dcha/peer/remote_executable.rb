module Dcha
  class Peer
    # :nodoc:
    module RemoteExecutable
      EXECUTABLE_OBJECT = %w[trie chain].freeze

      def execute(action, object_name = nil, params = [])
        return execute_on(self, action, params) if object_name.nil?
        object = pickup_object(object_name)
        return if object.nil?
        execute_on(object, action, params)
      end

      def execute_on(object, action, params = [])
        return unless object.respond_to?(action)
        object.send(action, *params)
      end

      def pickup_object(name)
        return unless EXECUTABLE_OBJECT.include?(name)
        instance_variable_get("@#{name}")
      end
    end
  end
end
