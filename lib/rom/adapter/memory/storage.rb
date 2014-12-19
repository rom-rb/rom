module ROM
  class Adapter
    class Memory < Adapter
      class Storage
        attr_reader :data

        def initialize(*)
          super
          @data = {}
        end

        def [](name)
          data[name]
        end

        def create_dataset(name, header)
          data[name] = Dataset.new([], header)
        end

        def key?(name)
          data.key?(name)
        end
      end
    end
  end
end
