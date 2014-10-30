require 'spec_helper'

describe 'Defining schema' do
  let(:rom) { ROM.setup(sqlite: SEQUEL_TEST_DB_URI) }

  before do
    seed(rom.sqlite.connection)
  end

  after do
    deseed(rom.sqlite.connection)
  end

  describe '.define' do
    it 'returns schema with relations' do
      rom.schema do
        base_relation(:users) do
          repository :sqlite
        end
      end

      schema = rom.schema
      users = schema.users

      expect(users.to_a).to eql(rom.sqlite.users.to_a)
      expect(users.header).to eql([:id, :name])
    end
  end
end
