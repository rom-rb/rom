require 'concord'
require 'sequel'

module ROM

  def self.setup(options, &block)
    adapters = options.each_with_object({}) do |(name, uri), hash|
      hash[name] = Adapter.setup(uri)
    end

    repositories = adapters.each_with_object({}) do |(name, adapter), hash|
      hash[name] = Repository.new(adapter)
    end

    env = Env.new(repositories)
    env.instance_exec(&block) if block
    env
  end

end

require 'rom/version'

require 'rom/header'
require 'rom/relation'
require 'rom/mapper'

require 'rom/adapter'
require 'rom/repository'
require 'rom/env'

require 'rom/schema'
require 'rom/mapping'
