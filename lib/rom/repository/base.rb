require 'anima'

module ROM
  class Repository
    class Base # :trollface:
      class ROM::Repository::Base
        attr_reader :models, :mappers

        def self.relations(*names)
          if names.any?
            attr_reader(*names)
            @relations = names
          else
            @relations
          end
        end

        def initialize(env)
          self.class.relations.each do |name|
            instance_variable_set("@#{name}", env.relations[name])
          end

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
              builder = ROM::ClassBuilder.new(name: "Mapper[#{component_name(relation)}]", parent: ROM::Mapper)

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

          models[header] ||= ROM::ClassBuilder.new(name: "ROM::Struct[#{component_name(relation)}]", parent: Object).call do |klass|
            klass.send(:include, Anima.new(*header))
          end
        end

        def component_name(relation)
          Inflector.classify(Inflector.singularize(relation.name))
        end
      end
    end
  end
end
