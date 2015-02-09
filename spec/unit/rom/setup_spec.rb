require 'spec_helper'

describe ROM::Setup do
  describe '#finalize' do
    context 'with repository that supports schema inferring' do
      it 'builds relation from inferred schema' do
        setup = ROM.setup(:memory)
        repo = setup.default
        dataset = double('dataset')

        allow(repo).to receive(:schema).and_return([:users])
        allow(repo).to receive(:dataset).with(:users).and_return(dataset)

        rom = setup.finalize

        expect(rom.relations.users.dataset).to be(dataset)
      end

      it 'skips inferring a relation when there is a defined one already' do
        setup = ROM.setup(:memory)
        repo = setup.default
        dataset = double('dataset')

        allow(repo).to receive(:schema).and_return([:users])
        allow(repo).to receive(:dataset).with(:users).and_return(dataset)

        class Users < ROM::Relation[:memory]; end

        expect { setup.finalize }.not_to raise_error

        rom = setup.env

        expect(rom.relations.users).to be_instance_of(Users)
      end

      it 'can register multiple relations with same dataset' do
        setup = ROM.setup(:memory)

        Class.new(ROM::Relation[:memory]) {
          dataset :fruits
          register_as :apples

          def apple?
            true
          end
        }

        Class.new(ROM::Relation[:memory]) {
          dataset :fruits
          register_as :oranges

          def orange?
            true
          end
        }

        rom = setup.finalize

        expect(rom.relations.apples).to be_apple
        expect(rom.relations.oranges).to be_orange
        expect(rom.relations.apples).to_not eq(rom.relations.oranges)
      end

      it "raises an error when registering relations with the same `register_as`" do
        setup = ROM.setup(:memory)

        Class.new(ROM::Relation[:memory]) {
          dataset :guests
          register_as :users
        }

        Class.new(ROM::Relation[:memory]) {
          dataset :admins
          register_as :users
        }

        expect { setup.finalize }.to raise_error(
          ROM::RelationAlreadyDefinedError, /register_as :users/
        )
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
