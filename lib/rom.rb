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
    adapters = options.each_with_object({}) do |(name, uri), hash|
      hash[name] = Adapter.setup(uri)
    end

    repositories = adapters.each_with_object({}) do |(name, adapter), hash|
      hash[name] = Repository.new(adapter)
    end

    Env.new(repositories)
  end

end

require 'rom/version'
require 'rom/adapter'
require 'rom/relation'
require 'rom/mapper'
