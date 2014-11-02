require 'spec_helper'

describe Adapter::Sequel do
  describe ".initialize" do
    it "sets up a connection based on the URI" do
      connection = Adapter::Sequel.new(SEQUEL_TEST_DB_URI).connection

      if USING_JRUBY
        expect(connection).to be_instance_of(Sequel::JDBC::Database)
      else
        expect(connection).to be_instance_of(Sequel::SQLite::Database)
      end
    end
  end

  describe ".schemes" do
    it "returns a list of schemes supported by Sequel" do
      schemes = [:ado, :amalgalite, :cubrid, :db2, :dbi, :do, :fdbsql, :firebird, :ibmdb,
                 :informix, :jdbc, :mysql, :mysql2, :odbc, :openbase, :oracle, :postgres,
                 :sqlanywhere, :sqlite, :swift, :tinytds]

      expect(described_class.schemes).to eq schemes
    end
  end
end
