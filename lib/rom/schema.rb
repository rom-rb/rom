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

  end # class Schema

end # module ROM
