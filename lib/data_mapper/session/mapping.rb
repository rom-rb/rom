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

      # Return mapping
      #
      # @return [Mapping]
      #
      # @api private
      #
      def mapping
        self
      end

      # Return model
      #
      # @return [Model]
      #
      # @api private
      #
      def model
        mapper.model
      end

      # Return new dump
      #
      # @return [Dump]
      #
      # @api private
      #
      def dump
        Dump.new(mapper.dumper(object))
      end
    end
  end
end
