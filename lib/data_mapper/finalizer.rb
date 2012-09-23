module DataMapper

  class Finalizer

    def self.run
      new(Mapper.descendants).run
    end

    def initialize(mappers)
      @mappers = mappers
    end

    def run
      finalize_base_relation_mappers
      finalize_attribute_mappers
      finalize_relationship_mappers

      self
    end

    private

    def finalize_base_relation_mappers
      @mappers.each { |mapper| mapper.finalize }
    end

    def finalize_attribute_mappers
      @mappers.each { |mapper| mapper.finalize_attributes }
    end

    def finalize_relationship_mappers
      @mappers.each { |mapper| mapper.finalize_relationships }
    end
  end # class Finalizer
end # module DataMapper
