require 'spec_helper'

describe ROM::Setup do
  describe '#finalize' do
    context 'with repository that supports schema inferring' do
      it 'builds relation from inferred schema' do
        repo = double('repo').as_null_object
        dataset = double('dataset')

        allow(repo).to receive(:schema).and_return([:users])
        allow(repo).to receive(:dataset).with(:users).and_return(dataset)

        setup = ROM::Setup.new(memory: repo)
        env = setup.finalize

        users = env.relations.users

        expect(users.dataset).to be(dataset)
      end
    end

    context 'empty setup' do
      let(:setup) { ROM::Setup.new({}) }
      let(:env) { setup.finalize }

      it 'builds empty repositories' do
        expect(env.repositories).to eql({})
      end

      it 'builds empty relations' do
        expect(env.relations).to eql(ROM::RelationRegistry.new)
      end

      it 'builds empty readers' do
        expect(env.readers).to eql(ROM::ReaderRegistry.new)
      end

      it 'builds empty commands' do
        expect(env.commands).to eql(ROM::Registry.new)
      end
    end
  end

  describe '#relation' do
    it 'raises error when same relation is defined more than once' do
      setup = ROM.setup(:memory)
      setup.relation(:users)

      expect { setup.relation(:users) }.to raise_error(
        ROM::RelationAlreadyDefinedError, /users/
      )
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
