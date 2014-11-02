require 'moped'

module ROM
  class Adapter

    class Mongo < Adapter
      attr_reader :connection

      def self.schemes
        [:mongo]
      end

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

      Adapter.register(self)
    end

  end
end
