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

  end

end
