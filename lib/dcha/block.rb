module Dcha
  # :nodoc:
  class Block
    attr_accessor :index, :hash, :root_hash, :parent_hash, :time, :proof

    def initialize(options = {})
      @time = Time.now.to_i
      @proof = ''
      options.each { |k, v| send("#{k}=", v) }
    end

    def valid_after?(previous_block)
      (previous_block.hash == parent_hash) &&
        (hash == Digest::SHA256.hexdigest(body.join)) &&
        valid_proof?
    end

    def body
      [index, time, root_hash, parent_hash]
    end

    def valid_proof?
      Digest::SHA256.hexdigest((body + [proof]).join).start_with?('abc')
    end

    def make_proof
      @hash = Digest::SHA256.hexdigest(body.join)
      letters = ('a'..'z').to_a
      @proof << letters.sample until valid_proof?
      self
    end

    # rubocop:disable Metrics/LineLength
    GENESIS = Block.new(index: 0, parent_hash: 0, time: 0, root_hash: "\0", proof: 'lvew')
  end
end
