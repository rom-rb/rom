require 'rom/mapper_builder/mapper_dsl'

module ROM
  class Mapper
    module DSL
      def self.included(klass)
        klass.extend(ClassMacros)
        klass.extend(ClassMethods)
      end

      module ClassMethods
        def base_relation
          if superclass.relation
            superclass.relation
          else
            relation
          end
        end

        def options
          { prefix: prefix, symbolize_keys: symbolize_keys }
        end

        def attributes
          @attributes ||= []
        end

        def header
          @header ||= dsl.header
        end

        private

        def dsl
          @dsl ||= MapperBuilder::MapperDSL.new(attributes, options)
        end

        def method_missing(name, *args, &block)
          if dsl.respond_to?(name)
            dsl.public_send(name, *args, &block)
          else
            super
          end
        end
      end
    end
  end
end
