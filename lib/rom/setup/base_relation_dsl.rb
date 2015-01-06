module ROM
  class Setup
    class BaseRelationDSL
      attr_reader :env, :name, :header

      def initialize(env, name, &block)
        @env = env
        @name = name
        @header = []
        @repository = nil
        instance_exec(&block)
      end

      def repository(name = nil)
        if @repository
          @repository
        else
          @repository = env[name]
        end
      end

      def attribute(name)
        warn <<-STRING
          ===========================================================
          Defining attributes in schema is no longer needed please
          move those definitions to the mappers (#{caller[0]})
          ===========================================================
        STRING

        header << name
      end

      def call
        dataset =
          if adapter.respond_to?(:dataset)
            adapter.dataset(name)
          else
            adapter[name]
          end

        [name, dataset]
      end

      private

      def adapter
        repository.adapter
      end
    end
  end
end
