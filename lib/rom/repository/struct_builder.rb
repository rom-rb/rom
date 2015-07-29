require 'anima'

require 'rom/struct'

module ROM
  class Repository < Gateway
    class StructBuilder
      attr_reader :registry

      def self.registry
        @__registry__ ||= {}
      end

      def initialize
        @registry = self.class.registry
      end

      def call(*args)
        name, columns = args
        registry[args.hash] ||= build_class(name) { |klass|
          klass.send(:include, Anima.new(*columns))
        }
      end
      alias_method :[], :call

      private

      def build_class(name, &block)
        ROM::ClassBuilder.new(name: class_name(name), parent: Struct).call(&block)
      end

      def class_name(name)
        "ROM::Struct[#{Inflector.classify(Inflector.singularize(name))}]"
      end
    end
  end
end
