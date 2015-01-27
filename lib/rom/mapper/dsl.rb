require 'rom/mapper_builder/mapper_dsl'

module ROM
  class Mapper
    module DSL
      def self.included(klass)
        klass.extend(ClassMacros)
        klass.extend(ClassMethods)
      end

      module ClassMethods
        def dsl
          @dsl ||= MapperBuilder::MapperDSL.new(attributes, options)
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
