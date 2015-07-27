require 'anima'

module ROM
  class Repository
    class Base # :trollface:
      class ROM::Repository::Base
        attr_reader :relation, :models, :mappers

        def initialize(relation)
          @relation = relation
          @mappers = {}
          @models = {}
        end

        def load
          result = yield
          mapper_for(result).call(result)
        end

        def mapper_for(relation)
          mappers[relation] ||=
            begin
              builder = ROM::ClassBuilder.new(name: "Mapper[#{component_name}]", parent: ROM::Mapper)

              mapper = builder.call do |klass|
                klass.model model_for(relation)

                relation.columns.each do |col|
                  klass.attribute col
                end
              end

              mapper.build
            end
        end

        def model_for(relation)
          header = relation.columns

          models[header] ||= ROM::ClassBuilder.new(name: "ROM::Struct[#{component_name}]", parent: Object).call do |klass|
            klass.send(:include, Anima.new(*header))
          end
        end

        def component_name
          Inflector.classify(Inflector.singularize(relation.name))
        end
      end
    end
  end
end
