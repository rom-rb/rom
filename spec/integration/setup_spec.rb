require 'spec_helper'

describe 'Setting up ROM' do
  context 'with existing schema' do
    include_context 'users and tasks'

    let(:jane) { { name: 'Jane', email: 'jane@doe.org' } }
    let(:joe) { { name: 'Joe', email: 'joe@doe.org' } }

    it 'configures relations' do
      expect(rom.memory.users).to match_array([joe, jane])
    end

    it 'raises on double-finalize' do
      expect {
        2.times { setup.finalize }
      }.to raise_error(ROM::EnvAlreadyFinalizedError)
    end
  end

  context 'without schema' do
    it 'builds empty registries if there is no schema' do
      setup = ROM.setup(memory: 'memory://test')

      setup.relation(:users)

      rom = setup.finalize

      expect(rom.relations).to eql(ROM::RelationRegistry.new)
      expect(rom.mappers).to eql(ROM::ReaderRegistry.new)
    end
  end
end
