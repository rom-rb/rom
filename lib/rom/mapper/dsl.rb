require 'rom/mapper/attribute_dsl'

module ROM
  class Mapper
    module DSL
      def self.included(klass)
        klass.extend(ClassMacros)
        klass.extend(ClassMethods)
      end

      module ClassMethods
        def inherited(klass)
          super

          klass.instance_variable_set('@attributes', nil)
          klass.instance_variable_set('@header', nil)
          klass.instance_variable_set('@dsl', nil)
        end

        def base_relation
          if superclass.relation
            superclass.relation
          else
            relation
          end
        end

        def header
          @header ||= dsl.header
        end

        private

        def options
          { prefix: prefix,
            prefix_separator: prefix_separator,
            symbolize_keys: symbolize_keys }
        end

        def attributes
          @attributes ||=
            if superclass.respond_to?(:attributes, true) && inherit_header
              superclass.attributes.dup
            else
              []
            end
        end

        def dsl
          @dsl ||= AttributeDSL.new(attributes, options)
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
