require 'spec_helper'

describe 'Setting up ROM' do
  context 'with existing schema' do
    include_context 'users and tasks'

    let(:jane) { { name: 'Jane', email: 'jane@doe.org' } }
    let(:joe) { { name: 'Joe', email: 'joe@doe.org' } }

    before do
      setup.relation(:users)
      setup.relation(:tasks)
    end

    it 'configures schema relations' do
      expect(rom.default.users).to match_array([joe, jane])
    end

    it 'configures rom relations' do
      users = rom.relations.users

      expect(users).to be_kind_of(ROM::Relation)
      expect(users).to respond_to(:tasks)

      tasks = users.tasks

      expect(tasks).to be_kind_of(ROM::Relation)
      expect(tasks).to respond_to(:users)
      expect(tasks.users).to be(users)
    end

    it 'raises on double-finalize' do
      expect {
        2.times { setup.finalize }
      }.to raise_error(ROM::EnvAlreadyFinalizedError)
    end
  end

  context 'without schema' do
    it 'builds empty registries if there is no schema' do
      setup = ROM.setup('memory://test')

      rom = setup.finalize

      expect(rom.relations).to eql(ROM::RelationRegistry.new)
      expect(rom.mappers).to eql(ROM::ReaderRegistry.new)
    end
  end

  describe 'quick setup' do
    it 'exposes boot DSL inside the setup block' do
      User = Class.new do
        include Virtus.value_object
        values { attribute :name, String }
      end

      rom = ROM.setup('memory://test') do
        relation(:users) do
          def by_name(name)
            restrict(name: name)
          end
        end

        commands(:users) do
          define(:create)
        end

        mappers do
          define(:users) do
            model User
          end
        end
      end

      rom.command(:users).try { create(name: 'Jane') }

      expect(rom.read(:users).by_name('Jane').to_a)
        .to eql([User.new(name: 'Jane')])
    end
  end

  describe 'multi-step setup' do
    it 'exposes boot DSL that can be invoked multiple times' do
      User = Class.new do
        include Virtus.value_object
        values { attribute :name, String }
      end

      ROM.setup('memory://test')

      ROM.relation(:users) do
        def by_name(name)
          restrict(name: name)
        end
      end

      ROM.commands(:users) do
        define(:create)
      end

      ROM.mappers do
        define(:users) do
          model User
        end
      end

      rom = ROM.finalize.env

      rom.command(:users).create.call(name: 'Jane')

      expect(rom.read(:users).by_name('Jane').to_a)
        .to eql([User.new(name: 'Jane')])
    end
  end

  describe 'setup with extra options' do
    shared_examples 'adapter with extra options' do
      subject(:adapter) { setup.default.adapter }

      it 'has connection uri' do
        expect(adapter.uri).to eql(
          Addressable::URI.parse('memory://localhost/test')
        )
      end

      it 'has extra options' do
        expect(adapter.options).to eql(super: 'option')
      end
    end

    context 'with a connection uri and options passed separately' do
      let(:setup) { ROM.setup('memory://localhost/test', super: 'option') }

      it_behaves_like 'adapter with extra options'
    end

    context 'with option hash' do
      let(:setup) do
        ROM.setup(adapter: 'memory', database: 'test', super: 'option')
      end

      it_behaves_like 'adapter with extra options'
    end
  end
end
