# frozen_string_literal: true

require "dry/container"

require_relative "initializer"
require_relative "types"

module ROM
  # Registry of all known component handlers
  #
  # @api public
  module Components
    extend Dry::Container::Mixin
    extend Enumerable
    extend self

    # @api private
    class Handler
      extend Initializer

      option :key, type: Types.Instance(Symbol)

      option :constant, type: Types.Interface(:new)

      option :namespace, type: Types.Instance(Symbol), default: -> { Inflector.namespace(key) }

      # @api private
      def build(**options)
        constant.new(**options)
      end
    end

    # @see ROM.components
    #
    # @return [Components]
    #
    # @api public
    def register(key, constant = nil, **options)
      Handler.new(key: key, constant: constant, **options).tap do |handler|
        super(handler.key, handler)
        # TODO: unify handler access
        super(handler.namespace, handler)
      end
      self
    end

    # Iterate over all registered component handlers
    #
    # @api public
    def each(&block)
      keys.each { |key| yield(resolve(key)) }
    end
  end
end
