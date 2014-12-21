module ROM
  # @private
  class MapperRegistry < Registry

    # @api private
    def []=(name, mapper)
      elements[name] = mapper
    end

    # @api private
    def by_path(path)
      elements[paths(path).detect { |name| elements.key?(name) }]
    end

    private

    # @api private
    def paths(path)
      path.split('.').map(&:to_sym).reverse
    end
  end
end
