# frozen_string_literal: true

require "dry/container"
require "dry/core/memoizable"

require_relative "constants"
require_relative "initializer"
require_relative "resolver"

module ROM
  class Registry
    extend Initializer

    include Dry::Core::Memoizable
    include Dry::Effects::Handler.Reader(:registry)
    include Enumerable

    class Container
      include Dry::Container::Mixin
    end

    option :config

    option :components

    option :container, default: -> { Container.new }

    option :resolver, default: -> { Resolver.new(components) }

    option :notifications, optional: true

    option :type, optional: true

    option :path, default: -> { EMPTY_ARRAY }

    option :root, default: -> { self }

    # @api public
    def fetch(key, &block)
      case key
      when Symbol
        if relation_scope?(key)
          scoped(key)
        else
          fetch([*path, key].join("."), &block)
        end
      when String
        return container[key] if container.key?(key)

        with_registry(root) { resolver.call(key, &block) }.tap { |item|
          container.register(key, item)
        }
      when Array
        MapperCompiler.new[key]
      end
    end
    alias_method :[], :fetch

    # @api private
    def relation_scope?(key)
      if !key?(key) && (mappers? || commands?)
        components.relations.map(&:id).include?(key)
      end
    end

    # @api private
    def scoped(*scope, **options)
      with(path: path + scope, **options)
    end

    Components::CORE_TYPES.each do |type|
      define_method(type) do
        scoped(__method__, type: __method__)
      end

      define_method(:"#{type}?") do
        self.type == type
      end
    end

    # @api private
    def each(&block)
      container.keys.each { |key| yield(fetch(key)) }
    end

    # @api private
    def plugins
      config.plugins
    end

    # @api private
    def trigger(event, payload)
      notifications.trigger(event, payload) if notifications
    end

    # @api private
    def ids
      resolver.ids
    end

    # @api private
    def keys
      resolver.keys
    end

    # @api private
    def key?(key)
      resolver.key?([*path, key].join("."))
    end

    # Disconnect all gateways
    #
    # @example
    #   rom = ROM.container(:sql, 'sqlite://my_db.sqlite')
    #   rom.relations[:users].insert(name: "Jane")
    #   rom.disconnect
    #
    # @return [Hash<Symbol=>Gateway>] a hash with disconnected gateways
    #
    # @api public
    def disconnect
      container.keys.grep(/gateways/).each { |key| self[key].disconnect }
    end
  end
end
