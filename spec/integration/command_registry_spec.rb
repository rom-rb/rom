require 'spec_helper'

describe 'ROM::CommandRegistry' do
  include_context 'container'

  let(:users) { container.command(:users) }

  before do
    configuration.relation(:users)

    configuration.register_command(Class.new(ROM::Commands::Create[:memory]) do
      register_as :create
      relation :users
      validator proc { |input| raise(ROM::CommandError) unless input[:name] }
    end)
  end

  describe '#try' do
    it 'returns a success result object on successful execution' do
      result = users.try { users.create.call(name: 'Jane') }

      expect(result).to match_array([{ name: 'Jane' }])
    end

    it 'returns a success result on successful curried-command execution' do
      result = users.try { users.create.curry(name: 'Jane') }

      expect(result).to match_array([{ name: 'Jane' }])
    end

    it 'returns a failure result object on failed execution' do
      result = users.try { users.create.call({}) }

      expect(result.value).to be(nil)
    end

    it 'returns a failure result on unsuccessful curried-command execution' do
      result = users.try { users.create.curry({}) }

      expect(result.value).to be(nil)
    end

    it 'allows checking if a command is available using respond_to?' do
      expect(users).to respond_to(:create)
    end
  end
end
