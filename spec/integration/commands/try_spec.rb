require 'spec_helper'

describe 'Commands / Try api' do
  include_context 'users and tasks'

  before do
    setup.relation(:users)

    setup.commands(:users) do
      define(:create)
    end
  end

  let(:user_commands) { rom.command(:users) }

  it 'exposes command functions inside the block' do
    input = { name: 'Piotr', email: 'piotr@test.com' }

    result = user_commands.try { create(input) }

    expect(result.value).to eql([input])
  end

  it 'passes command functions into the block' do
    input = { name: 'Piotr', email: 'piotr@test.com' }

    result = user_commands.try { |command| command.create(input) }

    expect(result.value).to eql([input])
  end

  it 'raises on method missing' do
    expect { user_commands.try { not_here } }
      .to raise_error(ROM::Registry::ElementNotFoundError)
  end
end
