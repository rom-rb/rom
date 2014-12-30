require 'spec_helper'

describe ROM::Setup do
  describe '#method_missing' do
    it 'returns a repository if it is defined' do
      repo = double('repo')
      setup = ROM::Setup.new(repo: repo)

      expect(setup.repo).to be(repo)
    end

    it 'raises error if repo is not defined' do
      setup = ROM::Setup.new({})

      expect { setup.not_here }.to raise_error(NoMethodError, /not_here/)
    end
  end
end
