module ROM

  class Relation
    include Concord::Public.new(:dataset)

    def each(&block)
      dataset.each(&block)
    end

  end

end
