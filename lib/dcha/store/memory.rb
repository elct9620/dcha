module Dcha
  module Store
    # :nodoc:
    class Memory < Hash
      def [](key)
        value = super
        raise DataUnavailableError, key if value.nil?
        value
      end
    end
  end
end
