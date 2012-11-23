module DataMapper
  class Session
    # Represent an object with its mapper
    class Mapping
      include Adamantium::Flat, Equalizer.new(:mapper, :object)

      # Return mapper
      #
      # @return [Mapper]
      #
      # @api private
      #
      attr_reader :mapper

      # Return object
      #
      # @return [Object]
      #
      # @api private
      #
      attr_reader :object

      # Initialize object
      #
      # @param [Mapper] mapper
      # @param [Object] object
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize(mapper, object)
        @mapper, @object = mapper, object
      end

      # Return identity
      #
      # @return [Object]
      #
      # @api private
      #
      def identity
        mapper.identity(object)
      end
      memoize :identity

      # Return mapping
      #
      # @return [Mapping]
      #
      # @api private
      #
      def mapping
        self
      end

      def tuple
        @mapper.dumper(object).tuple
      end
    end
  end
end
