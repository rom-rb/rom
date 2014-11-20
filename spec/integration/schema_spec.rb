require 'spec_helper'

describe 'Defining schema' do
  let(:setup) { ROM.setup(memory: 'memory://localhost') }
  let(:rom) { setup.finalize }
  let(:schema) { rom.schema }

  describe '.schema' do
    it 'returns schema with relations' do
      setup.schema do
        base_relation(:users) do
          repository :memory

          attribute :id
          attribute :name
        end
      end

      users = schema.users

      expect(users.dataset.to_a).to eql(rom.memory.users.to_a)
      expect(users.header).to eql([:id, :name])
    end

    it 'returns an empty schema if it was not defined' do
      expect(schema.users).to be_nil
    end
  end
end
