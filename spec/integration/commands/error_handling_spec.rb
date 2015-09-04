require 'spec_helper'

describe 'Commands / Error handling'  do
  include_context 'users and tasks'

  before do
    setup.relation(:users)
    setup.commands(:users) { define(:create) }
  end

  subject(:users) { rom.commands.users }

  it 'rescues from ROM::CommandError' do
    result = false
    expect(users.try { raise ROM::CommandError }.and_then { |_test| result = true })
      .to be_instance_of(Unsound::Data::Left)
    expect(result).to be(false)
  end

  it 'raises other errors' do
    expect { users.try { raise ArgumentError, 'test' } }
      .to raise_error(ArgumentError, 'test')
  end
end
