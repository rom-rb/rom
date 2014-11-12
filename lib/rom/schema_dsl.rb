module ROM

  class SchemaDSL
    attr_reader :env, :schema

    class BaseRelation
      attr_reader :env, :name, :repositories, :attributes, :datasets

      def initialize(env, name)
        @env = env
        @name = name
        @attributes = []
      end

      def repository(name = nil)
        if @repository
          @repository
        else
          @repository = env[name]
        end
      end

      def attribute(name)
        attributes << name
      end

      def call(&block)
        instance_exec(&block)

        dataset = repository[name]

        header =
          if attributes.any?
            attributes
          else
            dataset.header
          end

        Relation.new(repository[name], header)
      end
    end

    def initialize(env, schema = Schema.new)
      @env = env
      @schema = schema
    end

    def base_relation(name, &block)
      schema[name] = BaseRelation.new(env, name).call(&block)
    end

    def call
      schema
    end

  end

end
