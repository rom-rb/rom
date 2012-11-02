module DataMapper
  class Session
    # Abstract base class for object state
    class State
      include AbstractClass, Adamantium::Flat, Equalizer.new(:mapping, :dump)

      # Return domain object
      #
      # @return [Object]
      #
      # @api private
      #
      def object
        mapping.object
      end

      # Return transformer
      #
      # @return [#key, #dump]
      #
      # @api private
      #
      def transformer
        mapping.transformer
      end
      memoize :transformer

      # Return mapper
      #
      # @return [Mapper]
      #
      # @api private
      #
      def mapper
        mapping.mapper
      end

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
      def identity
        Identity.new(object.class, dump.key)
      end
      memoize :identity

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
        @mapping = context.mapping
        @dump    = context.dump
      end
    end
  end
end
