module ROM
  class Adapter

    class Memory < Adapter
      attr_reader :connection

      def self.schemes
        [:memory]
      end

      class Dataset
        include Charlatan.new(:data)

        def header
          []
        end
      end

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

      def initialize(*args)
        super
        @connection = Storage.new
      end

      def [](name)
        connection[name]
      end

      Adapter.register(self)
    end

  end
end
