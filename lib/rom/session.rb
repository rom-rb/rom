module ROM

  class Session
    include Concord.new(:registry)

    def [](relation_name)
      registry[relation_name]
    end


  end # Session

end # ROM
