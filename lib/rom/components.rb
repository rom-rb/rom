# frozen_string_literal: true

require "rom/constants"
require "rom/components/gateway"
require "rom/components/dataset"
require "rom/components/schema"
require "rom/components/relation"
require "rom/components/association"
require "rom/components/command"
require "rom/components/mapper"

module ROM
  # Setup objects collect component classes during setup/finalization process
  #
  # @api public
  module Components
    CORE_TYPES = %i[gateways datasets schemas relations associations commands mappers].freeze

    HANDLERS = {
      gateways: Gateway,
      datasets: Dataset,
      relations: Relation,
      associations: Association,
      commands: Command,
      mappers: Mapper,
      schemas: Schema
    }.freeze

    # @api private
    def inherited(klass)
      super
      klass.components.update(components)
    end

    # @api public
    def components
      @components ||= registry = Registry.new(owner: self)
    end

    class Registry
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
      def add(type, item: nil, **options)
        component = item || build(type, **options)

        if (other = store[type].detect { |c| c.key == component.key })
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
        delete(type, item) if keys(type).include?(component.key)
        store[type] << component
        component
      end

      # @api private
      def delete(type, item)
        self[type].delete(item)
        self
      end

      # @api private
      def update(other)
        other.each do |type, component|
          next if keys(type).include?(component.key)
          add(type, item: component.with(owner: owner))
        end
        self
      end

      # @api private
      def build(type, **options)
        handlers.fetch(type).new(**options, owner: owner)
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
