module ROM
  class Session

    # A database operation operand
    class Operand
      include Adamantium::Flat, Equalizer.new(:identity, :object, :tuple)

      # Initialize object
      #
      # @param [State] state
      #   the state used to initialize this instance
      #
      # @return [undefined]
      #
      # @api private
      def initialize(state)
        @identity, @object, @tuple = state.identity, state.object, state.tuple
      end

      # Return object
      #
      # @return [Object]
      #   a domain model instance
      #
      # @api private
      attr_reader :object

      # Return identity
      #
      # @return [Object]
      #   the object representing the identity
      #
      # @api private
      attr_reader :identity

      # Return tuple
      #
      # @return [#[]]
      #   the tuple used by this instance
      #
      # @api private
      #
      attr_reader :tuple

      class Update < self
        include Equalizer.new(:identity, :object, :tuple, :old_tuple)

        # Return old tuple
        #
        # @return [#[]]
        #   the tuple as it was before the update
        #
        # @api private
        attr_reader :old_tuple

        # Initialize object
        #
        # @param [State] state
        #   the state used to initialize this instance
        #
        # @param [#[]] old_tuple
        #   the old tuple used to initialize this instance
        #
        # @return [undefined]
        #
        # @api private
        def initialize(state, old_tuple)
          @old_tuple = old_tuple
          super(state)
        end
      end
    end
  end
end
