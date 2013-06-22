module ROM

  class Session
    include Concord.new(:environment)

    def [](relation_name)
      environment[relation_name]
    end

  end # Session

end # ROM
