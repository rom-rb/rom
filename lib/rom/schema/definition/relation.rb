# encoding: utf-8

module ROM
  class Schema
    class Definition

      # Builder object for Axiom relation
      #
      # @private
      class Relation
        include Equalizer.new(:header, :keys)

        # @api private
        def initialize(&block)
          @header = []
          @keys   = []
          instance_eval(&block)
        end

        # @api private
        def call(name)
          Axiom::Relation::Base.new(name, header)
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
        def key(*attribute_names)
          @keys.concat(attribute_names)
        end

      end # Relation

    end # Definition
  end # Schema
end # ROM
