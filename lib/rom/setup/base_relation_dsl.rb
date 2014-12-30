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
        header << name
      end

      def call
        dataset =
          if adapter.respond_to?(:dataset)
            adapter.dataset(name, header)
          else
            adapter[name]
          end

        base_header = dataset.respond_to?(:header) ? dataset.header : header

        [name, dataset, base_header]
      end

      private

      def adapter
        repository.adapter
      end
    end
  end
end
