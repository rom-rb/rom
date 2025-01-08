# frozen_string_literal: true

require 'concurrent/map'

module ROM
  # Thread-safe cache used by various rom components
  #
  # @api private
  class Cache
    attr_reader :objects

    # @api private
    class Namespaced
      # @api private
      attr_reader :cache

      # @api private
      attr_reader :namespace

      # @api private
      def initialize(cache, namespace)
        @cache = cache
        @namespace = namespace.to_sym
      end

      # @api private
      def [](key) = cache[[namespace, key].hash]

      # @api private
      def fetch_or_store(*args, &)
        cache.fetch_or_store([namespace, args].hash, &)
      end

      # @api private
      def size = cache.size

      # @api private
      def inspect = %(#<#{self.class} size=#{size}>)
    end

    # @api private
    def initialize
      @objects = ::Concurrent::Map.new
      @namespaced = {}
    end

    def [](key) = objects[key]

    # @api private
    def fetch_or_store(*args, &) = objects.fetch_or_store(args.hash, &)

    # @api private
    def size = objects.size

    # @api private
    def namespaced(namespace)
      @namespaced[namespace] ||= Namespaced.new(objects, namespace)
    end

    # @api private
    def inspect
      %(#<#{self.class} size=#{size} namespaced=#{@namespaced.inspect}>)
    end
  end
end
