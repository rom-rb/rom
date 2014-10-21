require 'spec_helper'

describe Schema do
  let(:rom) { ROM.setup(sqlite: 'sqlite::memory') }

  before do
    seed(rom.sqlite.connection)
  end

  describe '.define' do
    it "returns schema with relations" do
      rom.schema do
        base_relation(:users) do
          repository :sqlite

          attribute :id, Integer
          attribute :name, String
        end
      end

      header = Header.new(id: { type: Integer }, name: { type: String })

      schema = rom.schema

      expect(schema.users.to_a).to eql(rom.sqlite.users.to_a)
      expect(schema.users.header).to eql(header)
    end
  end
end
