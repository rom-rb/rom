require 'spec_helper'

RSpec.describe ROM::Container do
  include_context 'container'
  include_context 'users and tasks'

  before do
    users = Class.new(ROM::Relation[:memory]) do
      schema(:users) do
        attribute :name, ROM::Types::String
        attribute :email, ROM::Types::String
      end

      def by_name(name)
        restrict(name: name).project(:name)
      end
    end

    tasks = Class.new(ROM::Relation[:memory]) do
      schema(:tasks) do
        attribute :name, ROM::Types::String
        attribute :title, ROM::Types::String
        attribute :priority, ROM::Types::Integer
      end
    end

    create_user = Class.new(ROM::Commands::Create[:memory]) do
      relation :users
      register_as :create
    end

    create_task = Class.new(ROM::Commands::Create[:memory]) do
      relation :tasks
      register_as :create
    end

    users_mapper = Class.new(ROM::Mapper) do
      register_as :users
      relation :users
      attribute :name
      attribute :email
    end

    name_list = Class.new(users_mapper) do
      register_as :name_list
      attribute :name
      exclude :email
    end

    configuration.register_relation(users, tasks)
    configuration.register_command(create_user, create_task)
    configuration.register_mapper(users_mapper, name_list)
  end

  describe '#mappers' do
    it 'returns mappers for all relations' do
      expect(container.mappers.users[:name_list]).to_not be(nil)
    end
  end

  describe '#disconnect' do
    it 'does not break' do
      container.disconnect
    end
  end
end
