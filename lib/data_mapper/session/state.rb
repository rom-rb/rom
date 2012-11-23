module DataMapper
  class Session
    # Abstract base class for tracked state
    class State
      include AbstractClass, Adamantium::Flat, Equalizer.new(:identity, :object, :tuple, :mapper)

      # Return identity of object
      #
      # @return [Object]
      # 
      # @api private
      #
      attr_reader :identity

      # Return object associated with state
      #
      # @return [Object]
      #
      # @api private
      #
      attr_reader :object

      # Return mapper
      #
      # @return [Mapper]
      #
      # @api private
      #
      attr_reader :mapper

      # Return tuple
      # 
      # @return [Tuple]
      #
      # @api private
      #
      attr_reader :tuple

    private

      # Initialize object 
      #
      # @param [Mapping, State] context
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize(context)
        @mapper   = context.mapper
        @identity = context.identity
        @tuple    = context.tuple
        @object   = context.object
      end
    end
  end
end
