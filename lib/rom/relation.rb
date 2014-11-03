require 'charlatan'

module ROM

  class Relation
    include Charlatan.new(:dataset)

    undef_method :select

    attr_reader :header

    def initialize(dataset, header = dataset.header.dup)
      super
      @header = header.freeze
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
