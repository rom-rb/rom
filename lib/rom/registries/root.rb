# frozen_string_literal: true

require "dry/core/memoizable"

require_relative "../core"
require_relative "../constants"
require_relative "../initializer"
require_relative "../inferrer"
require_relative "container"

module ROM
  module Registries
    class Root
      extend Initializer

      include Dry::Core::Memoizable
      include Dry::Effects::Handler.Reader(:registry)
      include Enumerable

      CORE_COMPONENTS.each do |type|
        require_relative "#{type}"

        define_method(type) do |**options|
          registry = scoped(__method__, type: __method__, **options)

          klass =
            case type
            when :relations then Relations
            when :commands then Commands
            when :mappers then Mappers
            when :datasets then Datasets
            when :schemas then Schemas
            when :views then Views
            when :associations then Associations
            end

          klass ? klass.new(**registry.options) : registry
        end

        define_method(:"#{type}?") do
          self.type == type
        end
      end

      option :config, default: -> { ROM.config }

      option :components, default: -> { Components::Registry.new(provider: Runtime.new) }

      option :container, default: -> { Container.new }

      option :inferrer, default: -> { Inferrer.new }

      option :loader, optional: true

      option :notifications, optional: true

      option :type, optional: true

      option :path, default: -> { EMPTY_ARRAY }

      option :root, default: -> { self }

      option :opts, default: -> { EMPTY_HASH }

      # @api public
      def fetch(key, &block)
        case key
        when Symbol
          fetch("#{namespace}.#{key}", &block)
        when String
          return container[key] if container.key?(key)

          loader&.auto_load_component_file(type, key)

          with_registry(root) { build(key, &block) }.tap { |item|
            container.register(key, item)
          }
        when Array
          with_registry(self) { inferrer.call(key, type, **opts) }
        else
          if key.respond_to?(:to_sym)
            fetch(key.to_sym, &block)
          else
            element_not_found(key)
          end
        end
      rescue KeyError
        element_not_found(key)
      end
      alias_method :[], :fetch

      # @api public
      def infer(id, **options)
        fetch(id) do
          inferred_config = config[handler.key].inherit(**config.component, **options)
          define_component(id: id, **inferred_config).build
        end
      end

      # @api private
      def provider
        components.provider
      end

      # @api private
      def provider_type
        config.component.type
      end

      # @api private
      def handler
        components.handlers[type]
      end

      # @api private
      def build(key, &block)
        components.(key, &block)
      end

      # @api private
      memoize def namespace
        path.join(".")
      end

      # @api private
      memoize def compiler
        inferrer.compiler(type, **opts)
      end

      # @api private
      memoize def relation_ids
        components.relations.map(&:id)
      end

      # @api private
      def scoped(*scope, **options)
        with(path: path + scope, **options)
      end

      # @api private
      def each
        keys.each { |key| yield(fetch(key)) }
      end

      # @api private
      def plugins
        config.component.plugins
      end

      # @api private
      def trigger(event, payload)
        notifications&.trigger(event, payload)
      end

      # @api private
      def keys
        all = (components.keys + container.keys).uniq
        return all if path.empty?

        all.select { |key| key.start_with?(namespace) }
      end

      # @api private
      def ids
        components[type].map(&:id)
      end

      # @api private
      def key?(key)
        keys.include?("#{namespace}.#{key}")
      end

      # @api public
      def empty?
        keys.empty?
      end

      # @api private
      def inspect
        %(#<#{self.class} adapters=#{components.gateways.map(&:adapter)} keys=#{keys}>)
      end

      # Disconnect all gateways
      #
      # @example
      #   rom = ROM.runtime(:sql, 'sqlite://my_db.sqlite')
      #   rom.relations[:users].insert(name: "Jane")
      #   rom.disconnect
      #
      # @return [Hash<Symbol=>Gateway>] a hash with disconnected gateways
      #
      # @api public
      def disconnect
        container.keys.grep(/gateways/).each { |key| self[key].disconnect }
      end

      private

      # @api private
      def define_component(**options)
        provider.public_send(handler.key, **options)
      end

      # @api private
      def element_not_found(key)
        raise MISSING_ELEMENT_ERRORS.fetch(type).new(key)
      end
    end
  end
end
