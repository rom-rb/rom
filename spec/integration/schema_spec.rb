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

          attribute :user_id, Integer
          attribute :name, String
        end
      end

      header = Header.new(user_id: { type: Integer }, name: { type: String })

      schema = rom.schema

      expect(schema.users.to_a).to eql(rom.sqlite.users.to_a)
      expect(schema.users.header).to eql(header)
    end
  end
end
