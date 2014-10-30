module ROM

  class Repository
    include Concord::Public.new(:adapter)

    def [](name)
      adapter[name]
    end

    def connection
      adapter.connection
    end

    def respond_to_missing?(name, include_private = false)
      adapter[name]
    end

    private

    def method_missing(name)
      adapter[name]
    end
  end

end
