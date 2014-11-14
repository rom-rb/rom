require 'concord'

module ROM

  def self.setup(options, &block)
    adapters = options.each_with_object({}) do |(name, uri), hash|
      hash[name] = Adapter.setup(uri)
    end

    repositories = adapters.each_with_object({}) do |(name, adapter), hash|
      hash[name] = Repository.new(adapter)
    end

    boot = Boot.new(repositories)

    if block
      boot.instance_exec(&block)
      boot.finalize
    end

    boot
  end

end

require 'rom/version'

require 'rom/header'
require 'rom/relation'
require 'rom/mapper'
require 'rom/reader'

require 'rom/adapter'
require 'rom/repository'
require 'rom/env'

require 'rom/registry'
require 'rom/schema'
require 'rom/relation_registry'
require 'rom/reader_registry'

require 'rom/ra'

require 'rom/boot'
