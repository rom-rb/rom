# encoding: utf-8

module ROM
  class Schema
    class Definition

      # Builder object for Axiom relation
      #
      # @private
      class Relation
        include Equalizer.new(:header, :keys)

        attr_reader :registry

        # @api private
        def initialize(registry, &block)
          @registry = registry
          @header = []
          @keys   = []
          @wrappings = []
          instance_eval(&block)
        end

        # @api private
        def call(name)
          relation = Axiom::Relation::Base.new(name, header)

          if @wrappings.any?
            @wrappings.each { |wrapping| relation = relation.wrap(wrapping) }
          end

          relation
        end

        # @api private
        def header
          Axiom::Relation::Header.coerce(@header, keys: @keys)
        end

        # @api private
        def attribute(name, type)
          @header << [name, type]
        end

        # @api private
        def wrap(wrapping)
          @wrappings << wrapping
        end

        # @api private
        def key(*attribute_names)
          @keys.concat(attribute_names)
        end

        # @api private
        def method_missing(*args)
          registry[args.first] || super
        end

      end # Relation

    end # Definition
  end # Schema
end # ROM
