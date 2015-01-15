require 'rom/repository'
require 'rom/adapter/memory/storage'
require 'rom/adapter/memory/commands'

module ROM
  module Adapter
    module Memory
      class Repository < ROM::Repository
        attr_reader :logger

        def self.schemes
          [:memory]
        end

        def setup
          @connection = Storage.new
        end

        def use_logger(logger)
          @logger = logger
        end

        def dataset(name)
          self[name] || connection.create_dataset(name)
        end

        def dataset?(name)
          connection.key?(name)
        end

        def [](name)
          connection[name]
        end

        def command_namespace
          Memory::Commands
        end
      end
    end
  end
end
