module DataMapper
  class Session
    # Identity used for identity map
    #
    # This class scopes the key to model. This is needed to ensure
    # Keys are unique over all resources of differend models.
    #
    class Identity
      include Equalizer.new(:model, :key)

      # Return model
      #
      # @return [Class]
      #
      # @api private
      #
      attr_reader :model

      # Return key
      #
      # @return [Object]
      #
      # @api private
      #
      attr_reader :key

      # Initialize object
      #
      # @param [Class] model
      # @param [Object] key
      #
      # @api private
      #
      def initialize(model, key)
        @model, @key = model, key
      end
    end
  end
end
