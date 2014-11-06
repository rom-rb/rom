require 'spec_helper'

describe 'Setting up ROM' do
  subject(:rom) { ROM.setup(sqlite: SEQUEL_TEST_DB_URI) }

  let(:jane) { { id: 1, name: 'Jane' } }
  let(:joe) { { id: 2, name: 'Joe' } }

  before do
    seed(rom.sqlite.connection)
  end

  after do
    deseed(rom.sqlite.connection)
  end

  it 'configures relations' do
    expect(rom.sqlite.users.to_a).to eql([jane, joe])
  end
end
