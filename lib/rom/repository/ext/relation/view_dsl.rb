module ROM
  module SQL
    class Relation < ROM::Relation
      # View DSL evaluator
      #
      # @api private
      class ViewDSL
        attr_reader :name

        attr_reader :attributes

        attr_reader :relation_block

        def initialize(name, &block)
          @name = name
          instance_eval(&block)
        end

        def header(attributes)
          @attributes = attributes
        end

        def relation(&block)
          @relation_block = lambda(&block)
        end

        def call
          [name, attributes, relation_block]
        end
      end
    end
  end
end
