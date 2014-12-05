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
          data[name] ||= Dataset.new([])
        end

      end

    end
  end
end
