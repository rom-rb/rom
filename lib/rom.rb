require 'concord'
require 'sequel'

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

  class Repository
    include Concord::Public.new(:connection)

    def [](name)
      connection[name]
    end

    def respond_to_missing?(name, include_private = false)
      connection[name]
    end

    def method_missing(name, *args)
      Relation.new(connection[name])
    end
  end

  def self.setup(options)
    connections = options.each_with_object({}) do |(name, uri), hash|
      hash[name] = Sequel.connect(uri)
    end

    repositories = connections.each_with_object({}) do |(name, conn), hash|
      hash[name] = Repository.new(conn)
    end

    Env.new(repositories)
  end

end

require 'rom/version'
require 'rom/relation'
require 'rom/mapper'
