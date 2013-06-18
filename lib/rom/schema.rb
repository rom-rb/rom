module ROM

  class Schema
    include Concord.new(:definition)
    include Adamantium

    def self.build(&block)
      new(Definition.new(&block))
    end

    def [](name)
      definition[name]
    end

    def each(&block)
      definition.repositories.each(&block)
    end

  end # class Schema

end # module ROM
