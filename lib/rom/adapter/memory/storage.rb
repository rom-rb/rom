require 'thread_safe'
require 'rom/adapter/memory/dataset'

module ROM
  module Adapter
    module Memory
      class Storage
        attr_reader :data

        def initialize
          @data = ThreadSafe::Hash.new
        end

        def [](name)
          data[name]
        end

        def create_dataset(name)
          data[name] = Dataset.new(ThreadSafe::Array.new)
        end

        def key?(name)
          data.key?(name)
        end

        def size
          data.size
        end
      end
    end
  end
end
