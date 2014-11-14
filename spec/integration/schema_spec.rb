require 'spec_helper'

describe 'Defining schema' do
  subject(:rom) { setup.finalize }

  let(:setup) { ROM.setup(sqlite: SEQUEL_TEST_DB_URI) }

  before do
    seed(setup.sqlite.connection)
  end

  after do
    deseed(setup.sqlite.connection)
  end

  describe '.schema' do
    it 'returns schema with relations' do
      setup.schema do
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
  subject(:rom) { setup.finalize }

  let(:setup) { ROM.setup(sqlite: SEQUEL_TEST_DB_URI) }

  context "when database schema exists" do
    before do
      seed(setup.sqlite.connection)
    end

    after do
      deseed(setup.sqlite.connection)
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

      expect(schema.sqlite).to be(nil)
    end
  end

  context "for adapters that don't support inferring" do
    it "returns an empty schema" do
      setup = ROM.setup(memory: 'memory://test')
      setup.finalize

      expect(rom.schema.memory).to be(nil)
    end
  end
end
