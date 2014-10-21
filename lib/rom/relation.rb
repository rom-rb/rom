require 'charlatan'

module ROM

  class Relation
    include Charlatan.new(:dataset)
    include Enumerable

    attr_reader :header

    def initialize(dataset, header = Header.new)
      super
      @header = header
    end

    def each(&block)
      dataset.each(&block)
    end

  end

end
