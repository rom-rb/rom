module DataMapper

  # Abstract base class for database operations
  class Command
    include AbstractClass, Adamantium::Flat

    # Execute command
    #
    # @return [self]
    #
    # @api private
    #
    abstract_method :execute

    # Initialize command from state
    #
    # @param [State] state
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(state)
      @state = state
    end

    # Return state
    #
    # @return [State]
    #
    # @api private
    #
    attr_reader :state

    # Return mapper
    #
    # @return [Mapper]
    #
    # @api private
    #
    def mapper
      state.mapper.mapper
    end

    # Insert command
    class Insert < self
      # Execute command
      #
      # @return [self]
      #
      # @api private
      #
      def execute
        mapper.insert(state)
      end
    end

    # Update command
    class Update < self

      # Execute command
      #
      # @return [self]
      #
      # @api private
      #
      def execute
        mapper.update(state, old)
      end

      # Return old state
      #
      # @api private
      #
      # @return [State]
      #
      attr_reader :old

    private

      # Initialize object
      #
      # @param [State] new
      # @param [State] old
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize(new, old)
        @old = old
        super(new)
      end
    end

    # Delete command
    class Delete < self

      # Execute command
      #
      # @return [self]
      #
      # @api private
      #
      def execute
        mapper.delete(state)
      end
    end
  end
end
