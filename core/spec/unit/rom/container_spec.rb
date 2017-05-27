require 'spec_helper'

RSpec.describe ROM::Container do
  include_context 'container'
  include_context 'users and tasks'

  before do
    configuration

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
        attribute :priority, ROM::Types::Int
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

  describe '#command' do
    it 'returns registered command registry' do
      expect(container.command(:users)).to be_instance_of(ROM::CommandRegistry)
    end

    it 'returns registered command' do
      expect(container.command(:users).create).to be_kind_of(ROM::Commands::Create)
    end

    it 'accepts an array with graph options and input' do
      expect(container.command([:users, [:create]])).to be_kind_of(ROM::Commands::Lazy)
    end

    it 'raises ArgumentError when unsupported arg was passed' do
      expect { container.command(oops: 'sorry') }.to raise_error(ArgumentError)
    end
  end

  describe '#relation' do
    it 'yields selected relation to the block and returns a loaded relation' do
      result = container.relation(:users) { |r| r.by_name('Jane') }.as(:name_list)

      expect(result.call).to match_array([{ name: 'Jane' }])
    end

    it 'returns lazy-mapped relation' do
      by_name = container.relation(:users).as(:name_list).by_name

      expect(by_name['Jane']).to match_array([{ name: 'Jane' }])
    end

    it 'returns relation without mappers when mappers are not defined' do
      expect(container.relation(:tasks)).to be_kind_of(ROM::Relation)
      expect(container.relation(:tasks).mappers.elements).to be_empty
    end

    it 'returns a relation with finalized schema' do
      expect(container.relation(:tasks).schema.relations[:users]).to be(container.relations[:users])
    end
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
