# frozen_string_literal: true

require 'concurrent/map'

module ROM
  # Thread-safe cache used by various rom components
  #
  # @api private
  class Cache
    attr_reader :objects

    # Returns a cache key for the given object, expected to be a splat of args received directly
    # from a cache caller.
    #
    # Cache keying happens here so we have a chance to apply workarounds for different Ruby
    # implementations.
    #
    # Currently, this works around an issue with JRuby, where `Hash#hash` often returns the same
    # value for hashes that differ only by a module or class value. This impacts Rom relation ASTs,
    # which may differ only by their struct namespace.
    #
    # @api private
    def self.key(obj) = normalize(obj).hash

    # @api private
    def self.normalize(obj)
      case obj
      when ::Array then obj.map { normalize(_1) }
      when ::Hash then [::Hash, obj.map { |key, value| [normalize(key), normalize(value)] }]
      else obj
      end
    end
    private_class_method :normalize

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
      def [](key) = cache[Cache.key([namespace, key])]

      # @api private
      def fetch_or_store(*args, &)
        cache.fetch_or_store(Cache.key([namespace, args]), &)
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
    def fetch_or_store(*args, &) = objects.fetch_or_store(Cache.key(args), &)

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
