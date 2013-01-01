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
        @identity, @object, @tuple = state.identity, state.object, state.tuple
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
        include Equalizer.new(:identity, :object, :tuple, :old_tuple)

        # Return old tuple
        #
        # @return [Tuple]
        #
        # @api private
        #
        attr_reader :old_tuple

        # Initialize object
        #
        # @param [State] state
        # @param [Tuple] old_tuple
        #
        # @return [undefined]
        #
        # @api private
        #
        def initialize(state, old_tuple)
          @old_tuple = old_tuple
          super(state)
        end
      end
    end
  end
end
