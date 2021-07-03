# frozen_string_literal: true

require "rom/constants"
require "rom/components/schema"
require "rom/components/command"
require "rom/components/relation"
require "rom/components/mapper"

module ROM
  # Setup objects collect component classes during setup/finalization process
  #
  # @api public
  module Components
    CORE_TYPES = %i[schemas relations commands mappers].freeze

    HANDLERS = {
      relations: Relation,
      commands: Command,
      mappers: Mapper,
      schemas: Schema
    }.freeze

    # @api public
    def components
      @components ||= Registry.new
    end

    class Registry
      # @api private
      attr_reader :types

      # @api private
      attr_reader :store

      # @api private
      attr_reader :handlers

      DUPLICATE_ERRORS = {
        schemas: RelationAlreadyDefinedError,
        relations: RelationAlreadyDefinedError,
        commands: CommandAlreadyDefinedError,
        mappers: MapperAlreadyDefinedError
      }.freeze

      # @api private
      def initialize(types: CORE_TYPES.dup, handlers: HANDLERS)
        @types = types
        @store = types.map { |type| [type, EMPTY_ARRAY.dup] }.to_h
        @handlers = handlers
      end

      # @api private
      def [](type)
        store[type]
      end

      # @api private
      def update(other)
        store.each { |type, items| items.concat(other[type]) }
        self
      end

      # @api private
      def add(type, **options)
        component = handlers.fetch(type).new(**options)

        # TODO: this needs a nicer abstraction
        # TODO: respond_to? is only needed because auto_register specs use POROs :(
        update(component.constant.components) if component.constant.respond_to?(:components)

        # TODO: schemas not fully supported yet
        if type != :schemas && store[type].map(&:key).include?(component.key)
          raise DUPLICATE_ERRORS[type], "+#{component.id}+ is already defined"
        end

        store[type] << component

        component
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
