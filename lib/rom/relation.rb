module ROM

  class Relation
    include Concord::Public.new(:dataset)
    include Enumerable

    def each(&block)
      dataset.each(&block)
    end

  end

end
