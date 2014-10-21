require 'spec_helper'

describe Adapter do
  describe '.setup' do
    it 'sets up connection based on a uri' do
      connection = Adapter.setup('sqlite::memory')

      expect(connection).to be_instance_of(Sequel::SQLite::Database)
    end
  end
end
