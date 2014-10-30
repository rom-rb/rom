require 'spec_helper'

describe Adapter do
  describe '.setup' do
    it 'sets up connection based on a uri' do
      connection = Adapter.setup(SEQUEL_TEST_DB_URI).connection

      if USING_JRUBY
        expect(connection).to be_instance_of(Sequel::JDBC::Database)
      else
        expect(connection).to be_instance_of(Sequel::SQLite::Database)
      end

    end
  end
end
