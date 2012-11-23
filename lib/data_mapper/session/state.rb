module DataMapper
  class Session
    # Abstract base class for object state
    class State
      include AbstractClass, Adamantium::Flat, Equalizer.new(:mapping, :identity, :dump)

      # Return mapping
      #
      # @return [Mapping]
      #
      # @api private
      #
      attr_reader :mapping

      # Return dumped representation of object
      #
      # @return [Dump]
      #   the dumped representation
      #
      # @api private
      #
      attr_reader :dump

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
        @dump     = context.dump
      end
    end
  end
end
