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
end
