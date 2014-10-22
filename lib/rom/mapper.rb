module ROM

  class Mapper
    include Charlatan.new(:relation)
    include Enumerable

    attr_reader :header, :model

    def initialize(relation, header, model)
      super
      @header = header
      @model = model
    end

    def each(&block)
      relation.each { |tuple| yield(model.new(tuple)) }
    end

    def new(relation)
      self.class.new(relation, header, model)
    end

  end

end
