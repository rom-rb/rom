module ROM
  class Adapter

    class Sequel < Adapter
      attr_reader :connection

      def initialize(*args)
        super
        @connection = ::Sequel.connect(uri.to_s)
      end

    end

  end
end
