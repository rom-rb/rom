module Session
  # Represent an object with its mapper
  class Mapping
    include Immutable, Equalizer.new(:mapper, :object)

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

    # Return new dumped representation of object
    #
    # @return [Object]
    #
    # @api private
    #
    def dump
      mapper.dump(object)
    end

    # Return mapping
    #
    # @return [Mapping]
    #
    def mapping
      self
    end

    # Return new key representation of object
    #
    # @return [Object]
    #
    # @api private
    #
    def key
      mapper.dump_key(object)
    end
  end
end
