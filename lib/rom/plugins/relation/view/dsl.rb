module ROM
  module Plugins
    module Relation
      module View
        class DSL
          attr_reader :name

          attr_reader :attributes

          attr_reader :relation_block

          attr_reader :new_schema

          def initialize(name, schema = nil, &block)
            @name = name
            @schema = schema
            @new_schema = nil
            @attributes = nil
            @relation_block = nil
            instance_eval(&block)
          end

          def schema(&block)
            @new_schema = @schema.instance_exec(&block)
          end

          def header(*args, &block)
            @attributes = args.size > 0 ? args.first : block
          end

          def relation(&block)
            @relation_block = lambda(&block)
          end

          def call
            [name, attributes, relation_block, new_schema]
          end
        end
      end
    end
  end
end
