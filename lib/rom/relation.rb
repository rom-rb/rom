require 'charlatan'

module ROM

  class Relation
    include Charlatan.new(:dataset)
    include Enumerable

    def each(&block)
      dataset.each(&block)
    end

  end

end
