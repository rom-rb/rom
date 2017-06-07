require 'rom/registry'

module ROM
  # @private
  class MapperRegistry < Registry
    def self.element_not_found_error
      MapperMissingError
    end

    # @api private
    def []=(name, mapper)
      elements[name] = mapper
    end
  end
end
