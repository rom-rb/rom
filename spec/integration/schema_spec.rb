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

describe 'Inferring schema from database' do
  let(:rom) { ROM.setup(sqlite: SEQUEL_TEST_DB_URI) }

  context "when database schema exists" do

    before do
      seed(rom.sqlite.connection)
    end

    after do
      deseed(rom.sqlite.connection)
    end

    it "infers the schema from the database relations" do
      schema = rom.schema

      expect(schema.users.to_a).to eql(rom.sqlite.users.to_a)
      expect(schema.users.header).to eql([:id, :name])
    end
  end

  context "for empty database schemas" do
    it "returns an empty schema" do
      schema = rom.schema

      expect(schema.relations).to be_empty
    end
  end

  context "for adapters that don't support inferring" do
    it "returns an empty schema" do
      schema = ROM.setup(memory: 'memory://test').schema

      expect(schema.relations).to be_empty
    end
  end
end
