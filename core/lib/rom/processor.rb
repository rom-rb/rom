require 'rom/mapper'

module ROM
  # Abstract processor class
  #
  # Every ROM processor should inherit from this class
  #
  # @api public
  class Processor
    # Hook used to auto-register a processor class
    #
    # @api private
    def self.inherited(processor)
      Mapper.register_processor(processor)
    end

    # Required interface to be implemented by descendants
    #
    # @return [Processor]
    #
    # @abstract
    #
    # @api private
    def self.build
      raise NotImplementedError, "+build+ must be implemented"
    end
  end
end
