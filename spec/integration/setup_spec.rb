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
      expect(rom.readers).to eql(ROM::ReaderRegistry.new)
    end
  end

  describe 'defining classes' do
    class UserRelation < ROM::Relation[:memory]
      base_name :users

      def by_name(name)
        restrict(name: name)
      end
    end

    class TaskRelation < ROM::Relation[:memory]
      base_name :tasks
    end

    it 'sets up registries based on class definitions' do
      setup = ROM.setup(:memory)

      class CreateUser < ROM::Commands::Update[:memory]
        relation :users
        register_as :create
      end

      [UserRelation, TaskRelation].each do |klass|
        setup.register_relation(klass)
      end

      rom = ROM.finalize.env

      expect(rom.relations.users).to be_kind_of(UserRelation)
      expect(rom.relations.users.tasks).to be(rom.relations.tasks)

      expect(rom.commands.users[:create]).to be_kind_of(CreateUser)

      expect(rom.relations.tasks).to be_kind_of(TaskRelation)
      expect(rom.relations.tasks.users).to be(rom.relations.users)
    end
  end

  describe 'quick setup' do
    it 'exposes boot DSL inside the setup block' do
      User = Class.new do
        include Virtus.value_object
        values { attribute :name, String }
      end

      rom = ROM.setup(:memory) do
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

      rom.commands.users.create.call(name: 'Jane')

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
          model User
        end
      end

      rom = ROM.finalize.env

      rom.command(:users).create.call(name: 'Jane')

      expect(rom.read(:users).by_name('Jane').to_a)
        .to eql([User.new(name: 'Jane')])
    end
  end
end
