require 'dry/core/inflector'
require 'dry/core/cache'
require 'dry/core/class_builder'
require 'dry/struct'

require 'rom/struct'
require 'rom/repository/struct_attributes'
require 'rom/schema/type'

module ROM
  class Repository
    # @api private
    class StructBuilder
      extend Dry::Core::Cache

      def call(*args)
        fetch_or_store(*args) do
          name, header = args
          attributes = visit(header)

          if attributes.all? { |attr| attr.is_a?(Symbol) }
            build_class(name, ROM::Struct) { |klass|
              klass.send(:include, StructAttributes.new(attributes))
            }
          else
            build_class(name, Dry::Struct) { |klass|
              attributes.each { |attribute| klass.attribute(attribute.name, attribute.type) }
            }
          end
        end
      end
      alias_method :[], :call

      private

      def visit(ast)
        name, node = ast
        __send__("visit_#{name}", node)
      end

      def visit_header(node)
        node.map(&method(:visit))
      end

      def visit_relation(node)
        relation_name, meta, * = node
        meta[:combine_name] || relation_name.relation
      end

      def visit_attribute(node)
        node
      end

      def build_class(name, parent, &block)
        Dry::Core::ClassBuilder.new(name: class_name(name), parent: parent).call(&block)
      end

      def class_name(name)
        "ROM::Struct[#{Dry::Core::Inflector.classify(Dry::Core::Inflector.singularize(name))}]"
      end
    end
  end
end
