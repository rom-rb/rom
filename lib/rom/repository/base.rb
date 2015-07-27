require 'rom/repository/mapper_builder'

module ROM
  class Repository
    class Base # :trollface:
      class ROM::Repository::Base
        attr_reader :mapper_builder

        def self.relations(*names)
          if names.any?
            attr_reader(*names)
            @relations = names
          else
            @relations
          end
        end

        def self.new(env, mapper_builder = MapperBuilder.new)
          super
        end

        def initialize(env, mapper_builder)
          self.class.relations.each do |name|
            instance_variable_set("@#{name}", env.relations[name])
          end
          @mapper_builder = mapper_builder
        end

        def load
          result = yield
          mapper_builder[result].call(result)
        end
      end
    end
  end
end
