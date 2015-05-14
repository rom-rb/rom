require 'spec_helper'
require 'virtus'

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
      expect(rom.repositories[:default][:users]).to match_array([joe, jane])
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
      setup = ROM.setup(:memory)

      rom = setup.finalize

      expect(rom.relations).to eql(ROM::RelationRegistry.new)
      expect(rom.mappers).to eql(ROM::Registry.new)
    end
  end

  describe 'defining classes' do
    it 'sets up registries based on class definitions' do
      ROM.setup(:memory)

      class Test::UserRelation < ROM::Relation[:memory]
        dataset :users

        def by_name(name)
          restrict(name: name)
        end
      end

      class Test::TaskRelation < ROM::Relation[:memory]
        dataset :tasks
      end

      class Test::CreateUser < ROM::Commands::Update[:memory]
        relation :users
        register_as :create
      end

      rom = ROM.finalize.env

      expect(rom.relations.users).to be_kind_of(Test::UserRelation)
      expect(rom.relations.users.tasks).to be(rom.relations.tasks)

      expect(rom.commands.users[:create]).to be_kind_of(Test::CreateUser)

      expect(rom.relations.tasks).to be_kind_of(Test::TaskRelation)
      expect(rom.relations.tasks.users).to be(rom.relations.users)
    end
  end

  describe 'quick setup' do
    it 'exposes boot DSL inside the setup block' do
      module Test
        User = Class.new do
          include Virtus.value_object
          values { attribute :name, String }
        end
      end

      rom = ROM.setup(:memory) {
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
            model Test::User
          end
        end
      }

      rom.commands.users.create.call(name: 'Jane')

      expect(rom.relation(:users).by_name('Jane').as(:users).to_a)
        .to eql([Test::User.new(name: 'Jane')])
    end
  end

  describe 'multi-step setup' do
    it 'exposes boot DSL that can be invoked multiple times' do
      module Test
        User = Class.new do
          include Virtus.value_object
          values { attribute :name, String }
        end
      end

      ROM.setup(:memory)

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
          model Test::User
        end
      end

      rom = ROM.finalize.env

      rom.command(:users).create.call(name: 'Jane')

      expect(rom.relation(:users).by_name('Jane').as(:users).to_a)
        .to eql([Test::User.new(name: 'Jane')])
    end
  end
end
