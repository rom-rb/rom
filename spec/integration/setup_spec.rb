require 'spec_helper'

describe 'Setting up ROM' do
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
