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

    def initialize(config:, components: [], notifications: nil, **opts)
      @config = config
      @components = components
      @notifications = notifications
      @resolver = Resolver.new(components: components, **opts)
      @container = Container.new
      @opts = opts
    end

    # @api private
    def each(&block)
      resolver.each(&block)
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

    # @api private
    def key?(key)
      resolver.key?(key)
    end

    # @api public
    def resolve(key, &block)
      with_registry(self) { resolver.call(key, &block) }
    end
    alias_method :[], :resolve

    # @api private
    def new(**opts)
      self.class.new(
        config: config, components: components, notifications: notifications, **@opts, **opts
      )
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
  end
end
