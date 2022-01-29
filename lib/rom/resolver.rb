# frozen_string_literal: true

require "dry/container"
require "dry/core/memoizable"

require_relative "core"
require_relative "constants"
require_relative "initializer"
require_relative "inferrer"

module ROM
  class Resolver
    extend Initializer

    include Dry::Core::Memoizable
    include Dry::Effects::Handler.Reader(:resolver)
    include Enumerable

    MISSING_ELEMENT_ERRORS = {
      gateways: GatewayMissingError,
      schemas: SchemaMissingError,
      datasets: DatasetMissingError,
      relations: RelationMissingError,
      associations: RelationMissingError,
      commands: CommandNotFoundError,
      mappers: MapperMissingError
    }.freeze

    module Nestable
      # @api public
      def fetch(key, &block)
        if relation_namespace?(key)
          super(namespace, &block)
        elsif relation_scope_key?(key)
          scoped(key)
        else
          super(key, &block)
        end
      end
      alias_method :[], :fetch

      private

      # @api private
      def relation_namespace?(key)
        # TODO: stop nesting canonical mappers under relation's id ie `mappers.users.users`
        path.last == key && !mappers?
      end

      # @api private
      def relation_scope_key?(key)
        !key?(key) && relation_ids.include?(key)
      end
    end

    # @api public
    class Relations < Resolver
    end

    # @api public
    class Commands < Resolver
      prepend Nestable
    end

    # @api public
    class Mappers < Resolver
      prepend Nestable
    end

    # @api public
    class Datasets < Resolver
      prepend Nestable

      # @api private
      def infer_component(**options)
        return super unless provider_type == :relation

        comp = components.get(:datasets, relation_id: config.component.id, abstract: false)

        comp || super(**options, id: config.component.dataset, relation_id: config.component.id)
      end
    end

    # @api public
    class Schemas < Resolver
      prepend Nestable

      # @api private
      def infer_component(**options)
        return super unless provider_type == :relation

        comp = components.get(:schemas, relation: config.component.id, abstract: false)

        comp || super(**options, relation_id: config.component.id)
      end
    end

    # @api public
    class Views < Resolver
      prepend Nestable
    end

    # @api public
    class Associations < Resolver
      # @api public
      def fetch(key, &block)
        super(key) {
          components.key?(key) ? super(key, &block) : fetch_aliased_association(key)
        }
      end
      alias_method :[], :fetch

      private

      # @api private
      def fetch_aliased_association(key)
        components
          .associations(namespace: namespace)
          .detect { |assoc| key == "#{namespace}.#{assoc.config.name}" }
          .then { |assoc| fetch(assoc.config.as) if assoc }
      end
    end

    CORE_COMPONENTS.each do |type|
      define_method(type) do |**options|
        resolver = scoped(__method__, type: __method__, **options)

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

        klass ? klass.new(**resolver.options) : resolver
      end

      define_method(:"#{type}?") do
        self.type == type
      end
    end

    class Container
      include Dry::Container::Mixin
    end

    option :config, default: -> { ROM.config }

    option :components, default: -> { Components::Registry.new(provider: Runtime.new) }

    option :container, default: -> { Container.new }

    option :inferrer, default: -> { Inferrer.new }

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

        with_resolver(root) { build(key, &block) }.tap { |item|
          container.register(key, item)
        }
      when Array
        with_resolver(self) { inferrer.call(key, type, **opts) }
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
        infer_component(id: id, **inferred_config).build
      end
    end

    # @api private
    def infer_component(**options)
      provider.public_send(handler.key, **options)
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
    def element_not_found(key)
      raise MISSING_ELEMENT_ERRORS[type].new(key)
    end
  end
end
