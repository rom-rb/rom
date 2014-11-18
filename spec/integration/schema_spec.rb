require 'spec_helper'

describe 'Defining schema' do
  let(:setup) { ROM.setup(sqlite: SEQUEL_TEST_DB_URI) }

  describe '.schema' do
    it 'returns schema with relations' do
      setup.sqlite.connection.create_table :users do
        primary_key :id
        String :name
      end

      setup.schema do
        base_relation(:users) do
          repository :sqlite
        end
      end

      rom = setup.finalize
      schema = rom.schema
      users = schema.users

      expect(users.to_a).to eql(rom.sqlite.users.to_a)
      expect(users.header).to eql([:id, :name])
    end
  end
end

describe 'Inferring schema from database' do
  let(:setup) { ROM.setup(sqlite: SEQUEL_TEST_DB_URI) }

  context "when database schema exists" do
    it "infers the schema from the database relations" do
      setup.sqlite.connection.create_table :users do
        primary_key :id
        String :name
      end

      rom = setup.finalize
      schema = rom.schema

      expect(schema.users.to_a).to eql(rom.sqlite.users.to_a)
      expect(schema.users.header).to eql([:id, :name])
    end
  end

  context "for empty database schemas" do
    it "returns an empty schema" do
      rom = setup.finalize
      schema = rom.schema

      expect(schema.sqlite).to be(nil)
    end
  end

  context "for adapters that don't support inferring" do
    it "returns an empty schema" do
      rom = ROM.setup(memory: 'memory://test').finalize

      expect(rom.schema.memory).to be(nil)
    end
  end
end
