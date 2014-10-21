module ROM

  class Env
    include Concord::Public.new(:repositories)

    def respond_to_missing?(name, include_private = false)
      repositories.key?(name)
    end

    def method_missing(name, *args)
      repositories.fetch(name)
    end
  end

end
