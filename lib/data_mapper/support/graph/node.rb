class Graph
  class Node
    include Equalizer.new(:name)

    attr_reader :name

    def initialize(name)
      @name = name
    end
  end
end
