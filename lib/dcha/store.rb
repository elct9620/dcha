module Dcha
  # :nodoc:
  module Store
    class DataUnavailableError < StandardError; end

    autoload :Memory, 'dcha/store/memory'
    autoload :File, 'dcha/store/file'
  end
end
