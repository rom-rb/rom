require 'spec_helper'

describe 'Commands' do
  include_context 'users and tasks'

  let(:users) { rom.relations.users }

  before { setup.relation(:users) }

  describe '.build' do
    it 'returns create command when type is set to :create' do
      klass = Class.new(ROM::Commands::Create[:memory]) do
        relation :users
      end

      command = klass.build(users)

      expect(command).to be_kind_of(ROM::Memory::Commands::Create)
    end

    it 'returns update command when type is set to :update' do
      klass = Class.new(ROM::Commands::Update[:memory]) do
        relation :users
      end

      command = klass.build(users)

      expect(command).to be_kind_of(ROM::Memory::Commands::Update)
    end

    it 'returns delete command when type is set to :delete' do
      klass = Class.new(ROM::Commands::Delete[:memory]) do
        relation :users
      end

      command = klass.build(users)

      expect(command).to be_kind_of(ROM::Memory::Commands::Delete)
    end
  end

  describe '.registry' do
    it 'builds a hash with commands grouped by relations' do
      commands = {}

      [:Create, :Update, :Delete].each do |command_type|
        klass = Class.new(ROM::Commands.const_get(command_type)) do
          relation :users
        end
        klass.class_eval "def self.name; 'Test::#{command_type}'; end"
        commands[command_type] = klass
      end

      registry = ROM::Command.registry(rom.relations)

      expect(registry).to eql(
        users: {
          create: commands[:Create].build(users),
          update: commands[:Update].build(users),
          delete: commands[:Delete].build(users)
        }
      )
    end
  end

  describe '#>>' do
    let(:users) { double('users') }
    let(:tasks) { double('tasks') }
    let(:logs) { [] }

    it 'composes two commands' do
      user_input = { name: 'Jane' }
      user_tuple = { user_id: 1, name: 'Jane' }

      task_input = { title: 'Task One' }
      task_tuple = { user_id: 1, title: 'Task One' }

      create_user = Class.new(ROM::Commands::Create) {
        def execute(user_input)
          relation.insert(user_input)
        end
      }.build(users)

      create_task = Class.new(ROM::Commands::Create) {
        def execute(user_tuple, task_input)
          relation.insert(task_input.merge(user_id: user_tuple[:user_id]))
        end
      }.build(tasks)

      create_log = Class.new(ROM::Commands::Create) {
        result :one

        def execute(task_tuple)
          relation << task_tuple
        end
      }.build(logs)

      command = create_user.curry(user_input)
      command >>= create_task.curry(task_input)
      command >>= create_log

      expect(users).to receive(:insert).with(user_input).and_return(user_tuple)
      expect(tasks).to receive(:insert).with(task_tuple).and_return(task_tuple)

      result = command.call

      expect(result).to eql(task_tuple)
      expect(logs).to include(task_tuple)
    end
  end
end
