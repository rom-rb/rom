module DataMapper
  class Session
    # Abstract base class for object state
    class State
      include AbstractClass, Adamantium::Flat, Equalizer.new(:mapping, :identity, :tuple)

      # Return mapping
      #
      # @return [Mapping]
      #
      # @api private
      #
      attr_reader :mapping

      # Delete domain object
      #
      # Default implementation for all subclasses.
      #
      # @raise [StateError]
      #
      # @return [undefined]
      #
      # @api private
      #
      abstract_method :delete

      # Forget domain object
      #
      # Default implementation for all subclasses.
      #
      # @raise [StateError]
      #
      # @return [undefined]
      #
      # @api private
      #
      abstract_method :forget

      # Persist domain object
      #
      # Default implementation for all subclasses.
      #
      # @raise [StateError]
      #
      # @return [undefined]
      #
      # @api private
      #
      abstract_method :persist

      # Return identity of object
      #
      # @return [Object]
      # 
      # @api private
      #
      attr_reader :identity

      # Return object
      #
      # @api private
      #
      def object
        mapping.object
      end

      # Return mapper
      #
      # @return [Mapper]
      #
      # @api private
      #
      def mapper
        mapping.mapper
      end

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
      # @param [State,Mapping] context
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize(context)
        @mapping  = context.mapping
        @identity = context.identity
        @tuple    = context.tuple
      end
    end
  end
end
