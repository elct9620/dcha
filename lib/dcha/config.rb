module Dcha
  # :nodoc:
  class Config
    class << self
      def respond_to_missing?(name)
        instance.respond_to_missing?(name)
      end

      def method_missing(name, *args, &block)
        return instance.send(name, *args, &block) if instance.respond_to?(name)
        super
      end
    end

    include Singleton

    attr_accessor :digest, :store

    def initialize
      @digest = Digest::SHA256
      @store = Store::Memory.new
    end
  end
end
