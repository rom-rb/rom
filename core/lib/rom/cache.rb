require 'concurrent/map'

module ROM
  # @api private
  class Cache
    attr_reader :objects

    # @api private
    def initialize
      @objects = Concurrent::Map.new
    end

    # @api private
    def fetch_or_store(*args, &block)
      objects.fetch_or_store(args.hash, &block)
    end
  end
end
