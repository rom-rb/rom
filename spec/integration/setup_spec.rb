require 'spec_helper'
require 'virtus'

describe 'Configuring ROM' do
  context 'with existing schema' do
    include_context 'container'
    include_context 'users and tasks'

    let(:jane) { { name: 'Jane', email: 'jane@doe.org' } }
    let(:joe) { { name: 'Joe', email: 'joe@doe.org' } }

    before do
      configuration.relation(:users)
      configuration.relation(:tasks)
    end

    it 'configures schema relations' do
      expect(container.gateways[:default][:users]).to match_array([joe, jane])
    end

    it 'configures rom relations' do
      users = container.relations.users

      expect(users).to be_kind_of(ROM::Relation)
      expect(users).to respond_to(:tasks)

      tasks = users.tasks

      expect(tasks).to be_kind_of(ROM::Relation)
      expect(tasks).to respond_to(:users)
      expect(tasks.users).to be(users)
    end
  end

  context 'without schema' do
    it 'builds empty registries if there is no schema' do
      container = ROM.create_container(:memory)
      expect(container.relations).to eql(ROM::RelationRegistry.new)
      expect(container.mappers).to eql(ROM::Registry.new)
    end
  end

  describe 'defining classes' do
    it 'sets up registries based on class definitions' do
      container = ROM.create_container(:memory) do |config|
        config.use(:macros)

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

        config.register_relation(Test::UserRelation, Test::TaskRelation)
        config.register_command(Test::CreateUser)
      end

      expect(container.relations.users).to be_kind_of(Test::UserRelation)
      expect(container.relations.users.tasks).to be(container.relations.tasks)

      expect(container.commands.users[:create]).to be_kind_of(Test::CreateUser)

      expect(container.relations.tasks).to be_kind_of(Test::TaskRelation)
      expect(container.relations.tasks.users).to be(container.relations.users)
    end
  end

  describe 'quick setup' do
    # NOTE: move to DSL tests
    it 'exposes boot DSL inside the setup block via `macros` plugin' do
      module Test
        User = Class.new do
          include Virtus.value_object
          values { attribute :name, String }
        end
      end

      container = ROM.create_container(:memory) do |rom|
        rom.use(:macros)

        rom.relation(:users) do
          def by_name(name)
            restrict(name: name)
          end
        end

        rom.commands(:users) do
          define(:create)
        end

        rom.mappers do
          define(:users) do
            model Test::User
          end
        end
      end

      container.commands.users.create.call(name: 'Jane')

      expect(container.relation(:users).by_name('Jane').as(:users).to_a)
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

      configuration = ROM::Configuration.new(:memory).use(:macros)

      configuration.relation(:users) do
        def by_name(name)
          restrict(name: name)
        end
      end

      configuration.commands(:users) do
        define(:create)
      end

      configuration.mappers do
        define(:users) do
          model Test::User
        end
      end

      container = ROM.create_container(configuration)

      container.command(:users).create.call(name: 'Jane')

      expect(container.relation(:users).by_name('Jane').as(:users).to_a)
        .to eql([Test::User.new(name: 'Jane')])
    end
  end
end
