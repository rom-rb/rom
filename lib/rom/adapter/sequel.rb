class Sequel::Dataset
  alias_method :header, :columns
end

module ROM
  class Adapter

    class Sequel < Adapter
      attr_reader :connection

      def self.schemes
        [:ado, :amalgalite, :cubrid, :db2, :dbi, :do, :fdbsql, :firebird, :ibmdb,
         :informix, :jdbc, :mysql, :mysql2, :odbc, :openbase, :oracle, :postgres,
         :sqlanywhere, :sqlite, :swift, :tinytds]
      end

      def initialize(*args)
        super
        @connection = ::Sequel.connect(uri.to_s)
      end

      def [](name)
        connection[name]
      end

      def schema
        tables.map do |table|
          [table, dataset(table), dataset(table).columns]
        end
      end

      private

      def tables
        connection.tables
      end

      def dataset(table)
        connection[table]
      end

      def attributes(table)
        map_attribute_types connection.schema(table)
      end

      def map_attribute_types(attrs)
        attrs.map do |column, opts|
          [column, { type: map_schema_type(opts[:type]) }]
        end.to_h
      end

      def map_schema_type(type)
        connection.class::SCHEMA_TYPE_CLASSES.fetch(type)
      end

      Adapter.register(self)
    end

  end
end
