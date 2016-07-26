module ROM
  # Simple data-struct
  #
  # By default mappers use this as the model
  #
  # @api public
  class Struct
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
      instance_variable_get("@#{name}")
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
