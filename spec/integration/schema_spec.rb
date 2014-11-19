require 'spec_helper'

describe 'Defining schema' do
  let(:setup) { ROM.setup(memory: 'memory://localhost') }

  describe '.schema' do
    it 'returns schema with relations' do
      setup.schema do
        base_relation(:users) do
          repository :memory

          attribute :id
          attribute :name
        end
      end

      rom = setup.finalize
      schema = rom.schema
      users = schema.users

      expect(users.dataset.to_a).to eql(rom.memory.users.to_a)
      expect(users.header).to eql([:id, :name])
    end
  end
end
