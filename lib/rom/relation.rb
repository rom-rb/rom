require 'charlatan'

module ROM

  class Relation
    include Charlatan.new(:dataset)

    attr_reader :header

    def initialize(dataset, header = Header.new)
      super
      @header = header
    end

    def each(&block)
      return dataset.to_enum unless block
      dataset.each(&block)
    end

    def insert(tuple)
      dataset.insert(tuple)
      self
    end

    def update(tuple)
      dataset.update(tuple)
      self
    end

    def delete
      dataset.delete
      self
    end

  end

end
