require 'spec_helper'

RSpec.describe 'Commands / Error handling' do
  include_context 'container'
  include_context 'users and tasks'

  before do
    configuration.relation(:users)
    configuration.commands(:users) { define(:create) }
  end

  subject(:users) { container.commands.users }

  it 'rescues from ROM::CommandError' do
    result = false
    expect(users.try { raise ROM::CommandError } >-> _test { result = true })
      .to be_instance_of(ROM::Commands::Result::Failure)
    expect(result).to be(false)
  end

  it 'raises other errors' do
    expect { users.try { raise ArgumentError, 'test' } }
      .to raise_error(ArgumentError, 'test')
  end
end
