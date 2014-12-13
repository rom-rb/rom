require 'spec_helper'

describe 'Defining schema' do
  let(:setup) { ROM.setup(memory: 'memory://localhost') }
  let(:rom) { setup.finalize }
  let(:schema) { rom.schema }

  shared_context 'valid schema' do
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

  describe '.schema' do
    context 'with an adapter that supports header injection' do
      it_behaves_like 'valid schema'
    end

    context 'with an adapter that does not support header injection' do
      before do
        ROM::Adapter::Memory::Dataset.send(:undef_method, :header)
      end

      after do
        ROM::Adapter::Memory::Dataset.send(:attr_reader, :header)
      end

      it_behaves_like 'valid schema'
    end
  end
end
