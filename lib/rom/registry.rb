# frozen_string_literal: true

require "dry/container"

require_relative "resolver"

module ROM
  class Registry
    include Enumerable
    include Dry::Effects::Handler.Reader(:registry)

    class Container
      include Dry::Container::Mixin
    end

    attr_reader :config, :components, :container, :resolver, :notifications, :opts

    def initialize(config:, components: [], container: Container.new, notifications: nil, **opts)
      @config = config
      @components = components
      @notifications = notifications
      @resolver = Resolver.new(components: components, **opts)
      @container = container
      @opts = opts
    end

    # @api private
    def each(&block)
      container.keys.each { |key| yield resolve(key) }
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
    def namespace
      resolver.namespace
    end

    # @api private
    def keys
      resolver.keys
    end

    def ids
      resolver.ids
    end

    # @api private
    def key?(key)
      resolver.key?(key)
    end

    # @api public
    def resolve(key, &block)
      case key
      when Symbol
        qualified_key = [namespace, key].compact.join(".")

        return container[qualified_key] if container.key?(qualified_key)

        item = with_registry(self) { resolver.call(key, &block) }

        container.register(qualified_key, item)

        item
      when String
        return container[key] if container.key?(key)

        item = with_registry(self) { resolver.call(key, &block) }

        container.register(qualified_key, item)

        item
      when Array
        MapperCompiler.new[key]
      end
    end
    alias_method :[], :resolve

    # @api private
    def new(**opts)
      self.class.new(
        config: config,
        container: container,
        components: components,
        notifications: notifications,
        **@opts,
        **opts
      )
    end

    # @api private
    def namespaced(namespace)
      new(namespace: [self.namespace, namespace].compact.join("."))
    end

    # @api private
    def relations
      new(namespace: __method__)
    end

    # @api private
    def mappers
      new(namespace: __method__)
    end

    # @api private
    def datasets
      new(namespace: __method__)
    end

    # @api private
    def commands
      new(namespace: __method__)
    end

    # @api private
    def schemas
      new(namespace: __method__)
    end

    # @api private
    def gateways
      new(namespace: __method__)
    end

    # @api private
    def associations
      new(namespace: __method__)
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
