module DataMapper
  class Session
    # A unit of (database) work that is executed at once
    class Work

      # Initialize object
      #
      # @param [Registry] registry
      #
      # @api private
      #
      def initialize(registry)
        @registry = registry
        @commands = []
      end

      # Register command
      #
      # @param [Command] command
      #
      # @return [self]
      #
      # @api private
      #
      def register(command)
        @commands << command
        self
      end

      # Execute commands
      #
      # @return [self]
      #
      # @api private
      #
      def flush
        @commands.each do |command|
          command.execute
        end

        self
      end

      # Resolve object
      #
      # @return [Interceptor]
      #
      # @api private
      #
      def resolve_object(object)
        mapper = @registry.resolve_object(object)
        Interceptor.new(self, mapper)
      end

      # Resolve model
      #
      # @param [Model] model
      #
      # @return [Interceptor]
      #
      # @api private
      #
      def resolve_model(model)
        mapper = @registry.resolve_model(model)
        Interceptor.new(self, mapper)
      end
    end
  end
end
