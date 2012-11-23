module DataMapper

  class Session

    # A database operation operand
    class Operand
      include Adamantium::Flat, Equalizer.new(:identity, :object, :tuple)

      # Initialize object
      #
      # @param [State] state
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize(state)
        @identity = state.identity
        @object   = state.object
        @tuple    = state.tuple
      end

      # Return object
      #
      # @return [Object]
      #
      # @api private
      #
      attr_reader :object

      # Return identity
      #
      # @return [Identity]
      #
      # @api private
      #
      attr_reader :identity

      # Return tuple
      #
      # @return [Tuple]
      #
      # @api private
      #
      attr_reader :tuple

      class Update < self

        # Return old tuple
        #
        # @return [Tuple]
        #
        attr_reader :tuple

        # Initialize object
        #
        # @param [State::Dirty] state
        #
        # @return [undefined]
        #
        # @api private
        #
        def initialize(state)
          @old_tuple = state.old.tuple
          super(state)
        end
      end
    end
  end
end
