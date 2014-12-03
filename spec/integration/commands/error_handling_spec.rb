require 'spec_helper'

describe 'Commands / Error handling'  do
  include_context 'users and tasks'

  before do
    setup.relation(:users)
    setup.commands(:users) { define(:create) }
  end

  subject(:users) { rom.commands.users }

  it 'rescues from ROM::CommandError' do
    expect(users.try { raise ROM::CommandError }).to be_instance_of(ROM::Result::Failure)
  end

  it 'raises other errors' do
    expect { users.try { raise ArgumentError, 'test' } }.to raise_error(ArgumentError, 'test')
  end
end
