require 'moped'

module ROM
  class Adapter

    class Mongo < Adapter
      attr_reader :connection

      class Dataset
        include Charlatan.new(:collection, kind: Moped::Query)
      end

      def initialize(*args)
        super
        @connection = Moped::Session.new(["#{uri.host}:#{uri.port}"])
        @connection.use uri.path.gsub('/', '')
      end

      def [](name)
        Dataset.new(connection[name])
      end

      def schema
        []
      end

    end

  end
end
