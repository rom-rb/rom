# frozen_string_literal: true

require "dry/core/memoizable"

require "rom/constants"

module ROM
  # @api private
  class Resolver
    include Dry::Core::Memoizable
    include Enumerable

    attr_reader :components

    # @api private
    def initialize(components)
      @components = components
    end

    # @api private
    def call(key, &fallback)
      comp = get(key)

      if comp
        comp.build
      elsif fallback
        fallback.()
      else
        raise KeyError, "+#{key}+ not found"
      end
    end
    alias_method :[], :call

    # @api private
    def get(key)
      detect { |comp| comp.key == key }
    end

    # @api private
    def each(&block)
      components.each { |_, component| yield(component) }
    end

    # @api private
    def key?(key)
      keys.include?(key)
    end

    # @api private
    def ids
      map(&:id)
    end

    # @api private
    def keys
      map(&:key)
    end
  end
end
