require 'rom/support/class_builder'

module ROM
  # Simple data-struct
  #
  # By default mappers use this as the model
  #
  # @api public
  class Struct
    # Coerce to hash
    #
    # @return [Hash]
    #
    # @api private
    def to_hash
      to_h
    end

    # Access attribute value
    #
    # @param [Symbol] name The name of the attribute
    #
    # @return [Object]
    #
    # @api public
    def [](name)
      instance_variable_get("@#{name}")
    end

    # Return short string representaiton
    #
    # @return [String]
    #
    # @api public
    def to_s
      "#<#{self.class}:0x#{(object_id << 1).to_s(16)}>"
    end
  end
end
