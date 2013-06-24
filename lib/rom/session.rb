module ROM

  class Session
    include Concord.new(:environment)

    def self.start(environment, &block)
      yield(new(Environment.new(environment, Tracker.new)))
    end

    def [](relation_name)
      environment[relation_name]
    end

    def flush
      environment.commit
    end

  end # Session

end # ROM
