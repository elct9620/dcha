module Dcha
  module Store
    # :nodoc:
    class File < Hash
      def initialize(path)
        @path = Pathname.new(path).realdirpath
        Dir.mkdir(path) unless Dir.exist?(path)
      end

      def [](key)
        super || load_from(key)
      end

      def []=(key, value)
        save_to(key, value)
        super
      end

      def clear!
        FileUtils.rm_rf(path)
      end

      private

      def load_from(key)
        path = "#{@path}/#{key}"
        raise DataUnavailableError, key unless File.exist?(path)
        self[key] = File.read(path)
      end

      def save_to(key, value)
        path = "#{@path}/#{key}"
        File.write(path, value) unless File.exist?(path)
      end
    end
  end
end
