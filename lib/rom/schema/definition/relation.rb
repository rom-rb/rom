# encoding: utf-8

module ROM
  class Schema
    module Definition

      # Builder object for Axiom relation
      #
      # @private
      class Relation
        attr_reader :registry, :header, :keys, :wrappings, :groupings

        # Base relation builder object
        #
        class Base < self

          # @api private
          def repository(name = Undefined)
            if name == Undefined
              @repository
            else
              @repository = name
            end
          end

        end # Base

        # @api private
        def initialize(registry, &block)
          @registry = registry
          @header = []
          @keys   = []
          @wrappings = []
          @groupings = []
          instance_eval(&block)
        end

        # @api private
        def attribute(name, type, options = {})
          @header << [name, type, options]
        end

        # @api private
        def wrap(wrapping)
          @wrappings << wrapping
        end

        # @api private
        def group(grouping)
          @groupings << grouping
        end

        # @api private
        def key(*attribute_names)
          @keys.concat(attribute_names)
        end

        # @api private
        def renames
          header.each_with_object({}) { |ary, mapping|
            mapping[ary.first] = ary.last[:rename] if ary.last[:rename]
          }
        end

        private

        # @api private
        def method_missing(*args)
          registry[args.first] || super
        end

      end # Relation

    end # Definition
  end # Schema
end # ROM
