# frozen_string_literal: true

require "rom/constants"

require_relative "gateway"
require_relative "dataset"
require_relative "schema"
require_relative "relation"
require_relative "association"
require_relative "command"
require_relative "mapper"

module ROM
  # @api private
  module Components
    CORE_TYPES = %i[gateways datasets schemas relations associations commands mappers].freeze

    # @api public
    class Registry
      HANDLERS = {
        gateways: Gateway,
        datasets: Dataset,
        relations: Relation,
        associations: Association,
        commands: Command,
        mappers: Mapper,
        schemas: Schema
      }.freeze

      include Enumerable

      # @api private
      attr_reader :owner

      # @api private
      attr_reader :types

      # @api private
      attr_reader :store

      # @api private
      attr_reader :handlers

      DUPLICATE_ERRORS = {
        gateways: GatewayAlreadyDefinedError,
        datasets: DatasetAlreadyDefinedError,
        schemas: SchemaAlreadyDefinedError,
        relations: RelationAlreadyDefinedError,
        associations: AssociationAlreadyDefinedError,
        commands: CommandAlreadyDefinedError,
        mappers: MapperAlreadyDefinedError
      }.freeze

      # @api private
      def initialize(owner:, types: CORE_TYPES.dup, handlers: HANDLERS)
        @owner = owner
        @types = types
        @store = types.map { |type| [type, EMPTY_ARRAY.dup] }.to_h
        @handlers = handlers
      end

      # @api private
      def each
        store.each { |type, components|
          components.each { |component| yield(type, component) }
        }
      end

      # @api private
      def [](type)
        store[type]
      end

      # @api private
      def get(type, **opts)
        public_send(type, **opts).first
      end

      # @api private
      def add(type, item: nil, **options)
        component = item || build(type, **options)

        if include?(type, component)
          other = get(type, key: component.key)

          raise(
            DUPLICATE_ERRORS[type],
            "#{owner}: +#{component.key}+ is already defined by #{other.provider}"
          )
        end

        store[type] << component

        component
      end

      # @api private
      def replace(type, item: nil, **options)
        component = item || build(type, **options)
        delete(type, item) if include?(type, component)
        store[type] << component
        component
      end

      # @api private
      def delete(type, item)
        self[type].delete(item)
        self
      end

      # @api private
      def update(other, **options)
        other.each do |type, component|
          next if include?(type, component)
          add(type, item: component.with(owner: owner, **options))
        end
        self
      end

      # @api private
      def build(type, **options)
        handlers.fetch(type).new(**options, owner: owner)
      end

      # @api private
      def include?(type, component)
        !component.abstract? && keys(type).include?(component.key)
      end

      # @api private
      def keys(type)
        self[type].map(&:key)
      end

      CORE_TYPES.each do |type|
        define_method(type) do |**opts|
          all = self[type]
          return all if opts.empty?

          all.select { |el| opts.all? { |key, value| el.public_send(key).eql?(value) } }
        end
      end
    end
  end
end
