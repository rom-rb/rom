class Sequel::Dataset
  alias_method :header, :columns
end

module ROM
  class Adapter

    class Sequel < Adapter
      attr_reader :connection

      def initialize(*args)
        super
        @connection = ::Sequel.connect(uri.to_s)
      end

      def [](name)
        connection[name]
      end

    end

  end
end
