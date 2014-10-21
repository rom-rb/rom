require 'spec_helper'

describe Schema do
  let(:env) { ROM.setup(sqlite: 'sqlite::memory') }

  before do
    seed(env.sqlite.connection)
  end

  describe '.define' do
    it "returns schema with relations" do
      schema = Schema.define(env) do
        base_relation(:users) do
          repository :sqlite

          attribute :id, Integer
          attribute :name, String
        end
      end

      header = Header.new(id: { type: Integer }, name: { type: String })

      expect(schema.users.to_a).to eql(env.sqlite.users.to_a)
      expect(schema.users.header).to eql(header)
    end
  end
end
