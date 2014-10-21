module ROM
  class Adapter

    class Sequel < Adapter

      def connection
        ::Sequel.connect(uri.to_s)
      end

    end

  end
end
