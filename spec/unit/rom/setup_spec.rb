require 'spec_helper'

describe ROM::Setup do
  describe '#finalize' do
    context 'with an adapter that supports schema inferring' do
      it 'builds relation from inferred schema' do
        adapter = double('adapter').as_null_object
        repo = double('repo', adapter: adapter).as_null_object
        dataset = double('dataset', header: [:name, :email])

        allow(repo).to receive(:schema).and_return([
          [:users, dataset, [:name, :email]]
        ])

        setup = ROM::Setup.new(memory: repo)
        env = setup.finalize

        users = env.relations.users

        expect(users.dataset).to be(dataset)
        expect(users.header).to eql([:name, :email])
      end
    end
  end

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

  describe '#[]' do
    it 'returns a repository if it is defined' do
      repo = double('repo')
      setup = ROM::Setup.new(repo: repo)

      expect(setup[:repo]).to be(repo)
    end

    it 'raises error if repo is not defined' do
      setup = ROM::Setup.new({})

      expect { setup[:not_here] }.to raise_error(KeyError, /not_here/)
    end
  end
end
