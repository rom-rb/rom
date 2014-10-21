module ROM

  class Repository
    include Concord::Public.new(:connection)

    def [](name)
      connection[name]
    end

    def respond_to_missing?(name, include_private = false)
      connection[name]
    end

    def method_missing(name, *args)
      connection[name]
    end
  end

end
