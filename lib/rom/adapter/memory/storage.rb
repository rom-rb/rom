module ROM
  class Adapter
    class Memory < Adapter
      class Storage
        attr_reader :data

        def initialize
          @data = {}
        end

        def [](name)
          data[name]
        end

        def create_dataset(name)
          data[name] = Dataset.new([])
        end

        def key?(name)
          data.key?(name)
        end
      end
    end
  end
end
