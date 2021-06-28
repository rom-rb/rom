# frozen_string_literal: true

require "dry/core/equalizer"
require "dry/core/cache"
require "dry/core/class_builder"

require "rom/initializer"
require "rom/cache"
require "rom/constants"

module ROM
  # @api private
  class Registry
    extend Initializer
    extend Dry::Core::Cache

    include Enumerable
    include Dry::Equalizer(:elements)

    # @!attribute [r] elements
    #   @return [Hash] Internal hash for storing registry objects
    param :elements

    # @!attribute [r] resolvers
    #   @return [Hash<Symbol=>Proc>] Item resolvers
    option :resolvers, optional: true, default: -> { EMPTY_HASH.dup }

    # @!attribute [r] cache
    #   @return [Cache] local cache instance
    option :cache, default: -> { Cache.new }

    # @api private
    def self.new(*args, **kwargs)
      if args.empty? && kwargs.empty?
        super({}, **{})
      else
        super
      end
    end

    # Create a registry without options
    #
    # @api private
    def self.build(elements = {})
      new(elements, **{})
    end

    # @api private
    def self.[](identifier)
      fetch_or_store(identifier) do
        ::Dry::Core::ClassBuilder
          .new(parent: self, name: "#{name}[:#{identifier}]")
          .call
      end
    end

    # @api private
    def self.element_not_found_error
      ElementNotFoundError
    end

    # @api private
    def merge(other)
      self.class.new(Hash(other), **options)
    end

    # @api private
    def to_hash
      elements
    end

    # @api private
    def map
      new_elements = elements.each_with_object({}) do |(name, element), h|
        h[name] = yield(element)
      end
      self.class.new(new_elements, **options)
    end

    # @api private
    def each(&block)
      return to_enum unless block_given?

      elements.each(&block)
    end

    # @api private
    def each_key(&block)
      elements.each_key(&block)
    end

    # @api private
    def each_value(&block)
      elements.each_value(&block)
    end

    # @api private
    def keys
      elements.keys
    end

    # @api private
    def values
      elements.values
    end

    # @api private
    def add(key, element = nil, &block)
      raise self.class.element_already_defined_error, "+#{key}+ is already defined" if key?(key)

      if element
        elements[key] = element
      else
        resolvers[key] = block
      end
    end

    # @api private
    def fetch(key)
      raise ArgumentError, "key cannot be nil" if key.nil?

      elements.fetch(key.to_sym) do
        fallback = yield if block_given?

        return fallback if fallback

        raise self.class.element_not_found_error.new(key, self)
      end
    end
    alias_method :[], :fetch

    # This method handles resolving components at run-time
    #
    # @api private
    def resolve(key)
      add(key, resolvers.delete(key).())
    end

    # @api private
    def finalize
      resolvers.each_key do |key|
        resolve(key)
      end

      each_value { |element| element.finalize if element.respond_to?(:finalize) }

      self
    end

    # @api private
    def key?(key)
      !key.nil? && (elements.key?(key) || resolvers.key?(key))
    end

    # @api private
    def type
      self.class.name
    end

    # @api private
    def respond_to_missing?(name, include_private = false)
      key?(name) || super
    end

    private

    # @api private
    def method_missing(name, *)
      fetch(name) { super }
    end
  end
end
