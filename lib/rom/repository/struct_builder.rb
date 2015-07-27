require 'anima'

module ROM
  class Repository
    class StructBuilder
      attr_reader :registry

      def initialize
        @registry = {}
      end

      def call(relation)
        registry[relation.columns] ||= ROM::ClassBuilder.new(name: "ROM::Struct[#{component_name(relation)}]", parent: Object).call do |klass|
          klass.send(:include, Anima.new(*relation.columns))
        end
      end
      alias_method :[], :call

      def component_name(relation)
        Inflector.classify(Inflector.singularize(relation.name))
      end
    end
  end
end
