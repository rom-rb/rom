require 'dry/struct'

module ROM
  # Simple data-struct
  #
  # By default mappers use this as the model
  #
  # @api public
  class Struct < Dry::Struct
    # Returns a short string representation
    #
    # @return [String]
    #
    # @api public
    def to_s
      "#<#{self.class}:0x#{(object_id << 1).to_s(16)}>"
    end

    # Return attribute value
    #
    # @param [Symbol] name The attribute name
    #
    # @api public
    def fetch(name)
      __send__(name)
    end
  end
end
