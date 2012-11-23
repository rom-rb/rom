module DataMapper
  class Session
    # Represent an object with its mapper
    class Mapping
      include Adamantium::Flat, Equalizer.new(:mapper, :object, :identity, :tuple)

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

      # Return identity
      #
      # @return [Identity]
      #
      # @api private
      #
      def identity
        dumper.identity
      end

      # Return tuple
      #
      # @return [Tuple]
      #
      # @api private
      #
      def tuple
        dumper.tuple
      end

    private

      # Return dumper
      #
      # @return [Dumper]
      #
      # @api private
      #
      def dumper
        mapper.dumper(object)
      end
      memoize :dumper, :freezer => :noop

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

    end
  end
end
