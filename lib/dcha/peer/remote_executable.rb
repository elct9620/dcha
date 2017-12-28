module Dcha
  class Peer
    # :nodoc:
    module RemoteExecutable
      def execute(action, object = nil, params = [])
        return execute_on(self, action, params) if object.nil?
        object = instance_variable_get("@#{object}")
        return if object.nil?
        execute_on(object, action, params)
      end

      def execute_on(object, action, params = [])
        return unless object.respond_to?(action)
        object.send(action, *params)
      end
    end
  end
end
