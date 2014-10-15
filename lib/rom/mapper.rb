module ROM

  class Mapper
    include Concord::Public.new(:relation, :model)

    def each(&block)
      relation.each { |tuple| yield(model.new(tuple)) }
    end

  end

end
