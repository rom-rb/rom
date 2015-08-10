module ROM
  module Plugins
    module Relation
      module View
        class DSL
          attr_reader :name

          attr_reader :attributes

          attr_reader :relation_block

          def initialize(name, &block)
            @name = name
            instance_eval(&block)
          end

          def header(*args, &block)
            @attributes = args.size > 0 ? args.first : block
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
end
