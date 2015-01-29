require 'spec_helper'

describe 'Commands' do
  include_context 'users and tasks'

  let(:users) { rom.relations.users }

  before { setup.relation(:users) }

  describe '.build' do
    it 'returns create command when type is set to :create' do
      klass = Class.new(ROM::Command) do
        type :create
        adapter :memory
        relation :users
      end

      command = klass.build(users)

      expect(command).to be_kind_of(ROM::Memory::Commands::Create)
    end

    it 'returns update command when type is set to :update' do
      klass = Class.new(ROM::Command) do
        type :update
        adapter :memory
        relation :users
      end

      command = klass.build(users)

      expect(command).to be_kind_of(ROM::Memory::Commands::Update)
    end

    it 'returns delete command when type is set to :delete' do
      klass = Class.new(ROM::Command) do
        type :delete
        adapter :memory
        relation :users
      end

      command = klass.build(users)

      expect(command).to be_kind_of(ROM::Memory::Commands::Delete)
    end

    it 'raises error if type is not specified before adapter' do
      expect {
        Class.new(ROM::Command) { adapter :memory }
      }.to raise_error(ArgumentError, /type/)
    end
  end

  describe '.registry' do
    it 'builds a hash with commands grouped by relations' do
      commands = {}

      [:create, :update, :delete].each do |command_type|
        commands[command_type] = Class.new(ROM::Command) do
          type command_type
          adapter :memory
          relation :users
        end
      end

      registry = ROM::Command.registry(rom.relations)

      expect(registry).to eql(
        users: {
          create: commands[:create].build(users),
          update: commands[:update].build(users),
          delete: commands[:delete].build(users)
        }
      )
    end
  end
end
