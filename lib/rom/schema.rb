module ROM

  class Schema
    include Concord.new(:relations)
    include Adamantium

    def self.build(&block)
      new(Definition.relations(&block))
    end

    def [](name)
      relations[name]
    end

  end # class Schema

end # module ROM
