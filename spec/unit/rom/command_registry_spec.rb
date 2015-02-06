require 'spec_helper'

describe 'ROM::CommandRegistry' do
  subject(:env) { setup.finalize }

  let(:setup) { ROM.setup(:memory) }
  let(:users) { env.command(:users) }

  before do
    setup.relation(:users)

    setup.commands(:users) do
      define(:create) do
        validator proc { |input| raise(ROM::CommandError) unless input[:name] }
      end
    end
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
  end
end
