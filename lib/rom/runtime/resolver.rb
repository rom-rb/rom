# frozen_string_literal: true

require "delegate"

require "rom/constants"
require "rom/cache"
require "rom/command_compiler"

require_relative "configuration"

module ROM
  module Runtime
    class Resolver
      include Enumerable

      include Dry::Effects::Handler.Reader(:configuration)
      include Dry::Equalizer(:type, :cache, :opts)

      attr_reader :type, :namespace, :configuration, :cache, :opts

      MISSING_ELEMENT_ERRORS = {
        schemas: SchemaMissingError,
        relations: RelationMissingError,
        commands: CommandNotFoundError,
        mappers: MapperMissingError
      }.freeze

      # @api private
      def self.[](type)
        -> (items, **opts) {
          items.is_a?(self) ? items : new(type, items: items, **opts)
        }
      end

      # @api private
      def self.new(type, **opts)
        resolver = super
        configuration = resolver.configuration
        configuration.register(type, resolver) unless configuration.key?(type)
        resolver
      end

      # @api private
      def initialize(type, namespace: type, configuration: Configuration.new, cache: Cache.new, **opts)
        @type = type
        @namespace = namespace.to_s
        @configuration = configuration
        @cache = cache.namespaced(namespace)
        @opts = opts.merge(configuration: configuration, cache: cache)
        preload if opts[:items]
      end

      # @api private
      def component_options
        opts[:component] || EMPTY_HASH
      end

      # @api public
      def each
        ids.each { |id| yield(self[id]) }
      end
      alias_method :each_value, :each

      # @api public
      def empty?
        keys.empty?
      end

      # @api private
      def _update(components)
        configuration.components.update(components)
        self
      end

      # @api private
      def preload
        opts[:items].each do |id, object|
          configuration.components.add(type, id: id, namespace: namespace, object: object)
        end
      end

      # @api private
      def new(new_ns = nil, **opts)
        if new_ns
          self.class.new(type, namespace: "#{namespace}.#{new_ns}", **@opts, **opts)
        else
          self.class.new(type, **@opts, **opts, namespace: namespace)
        end
      end

      # @api public
      def fetch(*args)
        cache.fetch_or_store(args.hash) { with_configuration(configuration) { call(*args) } }
      end
      alias_method :[], :fetch

      # @api private
      def call(*args)
        if args.size.equal?(1) && !(val = args.first).is_a?(Array) && val.respond_to?(:to_sym)
          id = val.to_sym
          key = "#{namespace}.#{id}"

          if root?(id) && !key?(key)
            new(id)
          elsif key?(key)
            if component_options.empty?
              component(key).build
            else
              component(key).build(**component_options)
            end
          else
            raise MISSING_ELEMENT_ERRORS[type].new(key)
          end
        else
          # TODO: this should be unified
          if type == :commands
            compiler[*args]
          else
            compiler[val]
          end
        end
      end

      # TODO: move to rom/compat
      #
      # @api public
      #
      # @deprecated
      def map_with(*names)
        new(component: {map_with: names})
      end

      # @api public
      def key?(key)
        keys.include?(key) || keys.include?("#{namespace}.#{key}")
      end

      # @api public
      def root?(key)
        type != :relations && configuration.components.relations.map(&:id).include?(key)
      end

      # @api public
      def ids
        components.map(&:id)
      end

      # @api public
      def keys
        components.map(&:key)
      end

      # @api private
      def components
        configuration.components[type].select { |component| component.namespace.eql?(namespace) }
      end

      # @api private
      def component(key)
        components.detect { |component| component.key.eql?(key) }
      end

      # @api private
      def component?(key)
        !component(key).nil?
      end

      # @api private
      def compiler
        @compiler ||=
        case type
        when :commands then command_compiler
        when :mappers then mapper_compiler
        end
      end

      # @api private
      def adapter
        ROM.adapters[opts[:adapter]]
      end

      private

      # @api private
      def relation_id
        namespace.split(".").last
      end

      # @api private
      def command_compiler
        CommandCompiler.new(
          relations: configuration.relations,
          commands: configuration.commands.new(relation_id),
          cache: cache
        )
      end

      # @api private
      def mapper_compiler
        if adapter && adapter.const_defined?(:MapperCompiler)
          adapter::MapperCompiler
        else
          MapperCompiler
        end.new(cache: cache)
      end

      # @api private
      def respond_to_missing?(name, *)
        key = "#{namespace}.#{name.to_sym}"
        super || key?(key)
      end

      # @api private
      def method_missing(name, *)
        key = "#{namespace}.#{name}"

        if root?(name) && !key?(key)
          new(name)
        elsif key?(key)
          self[name]
        else
          super
        end
      end
    end
  end
end
