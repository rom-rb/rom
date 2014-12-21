module ROM
  # @private
  class MapperRegistry < Registry
    def []=(name, mapper)
      elements[name] = mapper
    end

    def key?(name)
      elements.key?(name)
    end
  end
end
