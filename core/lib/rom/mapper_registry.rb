require 'rom/registry'

module ROM
  # @private
  class MapperRegistry < Registry
    # @api private
    def []=(name, mapper)
      elements[name] = mapper
    end

    # @api private
    def [](name)
      elements.fetch(name) { raise(MapperMissingError, name) }
    end

    # @api private
    def key?(name)
      elements.key?(name)
    end

    # @api private
    def by_path(path)
      elements.fetch(paths(path).detect { |name| elements.key?(name) }) {
        raise(MapperMissingError, path)
      }
    end

    private

    # @api private
    def paths(path)
      path.split('.').map(&:to_sym).reverse
    end
  end
end
