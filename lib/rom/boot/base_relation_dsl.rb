module ROM
  class Boot

    class BaseRelationDSL
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

        [repository[name], header, repository.adapter]
      end

    end

  end
end
