require 'spec_helper'

describe 'Defining schema' do
  let(:rom) { ROM.setup(sqlite: SEQUEL_TEST_DB_URI, memory: 'memory://test') }

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

        base_relation(:tasks) do
          repository :memory

          attribute :name, String
          attribute :title, String
        end

        relation(:users_with_tasks) do
          join(users, tasks)
        end
      end

      header = Header.new(user_id: { type: Integer }, name: { type: String })

      schema = rom.schema

      schema.tasks << { name: 'Joe', title: 'Be happy' }

      expect(schema.users.to_a).to eql(rom.sqlite.users.to_a)
      expect(schema.users.header).to eql(header)

      expect(schema.users_with_tasks.to_a).to eql([{ id: 2, name: 'Joe', title: 'Be happy' }])
    end
  end
end
