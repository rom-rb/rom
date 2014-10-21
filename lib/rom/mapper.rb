module ROM

  class Mapper
    include Concord::Public.new(:relation, :header, :model)
    include Enumerable

    def each(&block)
      relation.each { |tuple| yield(model.new(tuple)) }
    end

  end

end
