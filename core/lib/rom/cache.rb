require 'concurrent/map'

module ROM
  # @api private
  class Cache
    attr_reader :objects

    class Namespaced
      attr_reader :cache

      attr_reader :namespace

      def initialize(cache, namespace)
        @cache = cache
        @namespace = namespace.to_sym
      end

      def [](key)
        cache[[namespace, key].hash]
      end

      def fetch_or_store(*args, &block)
        cache.fetch_or_store([namespace, args.hash].hash, &block)
      end

      def namespaced?
        true
      end
    end

    # @api private
    def initialize
      @objects = Concurrent::Map.new
    end

    def [](key)
      cache[key]
    end

    def namespaced?
      false
    end

    # @api private
    def fetch_or_store(*args, &block)
      objects.fetch_or_store(args.hash, &block)
    end

    def namespaced(namespace)
      Namespaced.new(objects, namespace)
    end
  end
end
