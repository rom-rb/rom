module ROM
  # @private
  class MapperRegistry < Registry
    def []=(name, mapper)
      elements[name] = mapper
    end

    def key?(name)
      elements.key?(name)
    end

    def by_path(path)
      names = path.split('.').map(&:to_sym)
      mapper_key = names.reverse.detect { |name| key?(name) }
      elements[mapper_key]
    end
  end
end
