module ROM
  class Adapter

    class Memory < Adapter
      attr_reader :connection

      class Storage
        attr_reader :data

        def initialize(*)
          super
          @data = {}
        end

        def [](name)
          data[name] ||= []
        end
      end

      def initialize(*args)
        super
        @connection = Storage.new
      end

    end

  end
end
