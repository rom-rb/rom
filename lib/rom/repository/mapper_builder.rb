require 'rom/repository/struct_builder'

module ROM
  class Repository
    class MapperBuilder
      attr_reader :struct_builder

      attr_reader :registry

      def self.new(struct_builder = StructBuilder.new)
        super
      end

      def initialize(struct_builder)
        @struct_builder = struct_builder
        @registry = {}
      end

      def call(relation)
        registry[relation] ||=
          begin
            builder = ROM::ClassBuilder.new(name: "Mapper[#{component_name(relation)}]", parent: ROM::Mapper)

            mapper = builder.call do |klass|
              klass.model struct_builder[relation]

              relation.columns.each do |col|
                klass.attribute col
              end
            end

            mapper.build
          end
      end

      def component_name(relation)
        Inflector.classify(Inflector.singularize(relation.name))
      end
      alias_method :[], :call
    end
  end
end
