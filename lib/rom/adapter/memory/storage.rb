require 'thread_safe'

module ROM
  class Adapter
    class Memory < Adapter
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
