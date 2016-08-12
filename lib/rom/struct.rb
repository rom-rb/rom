module ROM
  # Simple data-struct
  #
  # By default mappers use this as the model
  #
  # @api public
  class Struct
    # Error on building a struct instance
    #
    # @api private
    class InvalidAttributes < ArgumentError
      # @api private
      def initialize(klass, missing, unknown)
        super("#{klass} attributes " \
              "missing: #{missing.map(&:inspect).join(', ')}, " \
              "unknown: #{unknown.map(&:inspect).join(', ')}")
      end
    end
    # Coerces a struct to a hash
    #
    # @return [Hash]
    #
    # @api private
    def to_hash
      to_h
    end

    # Reads an attribute value
    #
    # @param name [Symbol] The name of the attribute
    #
    # @return [Object]
    #
    # @api public
    def [](name)
      __send__(name)
    end

    # Returns a short string representation
    #
    # @return [String]
    #
    # @api public
    def to_s
      "#<#{self.class}:0x#{(object_id << 1).to_s(16)}>"
    end
  end
end
