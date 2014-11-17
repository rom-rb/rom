require 'spec_helper'

describe 'Setting up ROM' do
  include_context 'users and tasks'

  let(:jane) { { name: 'Jane', email: 'jane@doe.org' } }
  let(:joe) { { name: 'Joe', email: 'joe@doe.org' } }

  it 'configures relations' do
    expect(rom.sqlite.users.to_a).to eql([joe, jane])
  end
end
