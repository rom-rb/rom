require 'rom/struct'

module ROM
  class Repository
    # @api private
    class StructAttributes < Module
      def initialize(attributes)
        super()

        define_constructor(attributes)

        module_eval do
          include Dry::Equalizer.new(*attributes)
          attr_reader *attributes

          define_method(:to_h) do
            attributes.each_with_object({}) do |attribute, h|
              h[attribute] = public_send(attribute)
            end
          end
        end
      end

      def define_constructor(attributes)
        kwargs = attributes.map { |a| "#{a}: " }.join(', ')
        ivs = attributes.map { |a| "@#{a}" }.join(', ')
        values = attributes.join(', ')

        module_eval(<<-RUBY, __FILE__, __LINE__ + 1)
          def initialize(#{kwargs})
            #{ivs} = #{values}
          end
        RUBY
      end
    end

    # @api private
    class StructBuilder
      attr_reader :registry

      def self.registry
        @__registry__ ||= {}
      end

      def initialize
        @registry = self.class.registry
      end

      def call(*args)
        name, header = args

        registry[args.hash] ||= build_class(name) { |klass|
          klass.send(:include, StructAttributes.new(visit(header)))
        }
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
        name, * = node
        name
      end

      def visit_attribute(node)
        node
      end

      def build_class(name, &block)
        ROM::ClassBuilder.new(name: class_name(name), parent: Struct).call(&block)
      end

      def class_name(name)
        "ROM::Struct[#{Inflector.classify(Inflector.singularize(name))}]"
      end
    end
  end
end
