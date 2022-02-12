# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Commands" do
  include_context "gateway only"
  include_context "users and tasks"

  let(:users_relation) do
    Class.new(ROM::Memory::Relation) do
      def by_id(id)
        restrict(id: id)
      end
    end.new(users_dataset)
  end

  describe "custom command component" do
    it "creates a command class constant" do
      config = ROM::Setup.new do |config|
        config.commands(:users, adapter: :memory) do
          define(:create) do
            def super?
              true
            end
          end
        end
      end

      klass = config.components.commands(id: :create).first.constant

      expect(klass.name).to eql("ROM::Memory::Commands::Create[Users]")
      expect(klass.config.component.id).to eql(:create)

      command = klass.build(users_relation)

      expect(command).to be_a(ROM::Memory::Commands::Create)
      expect(command).to be_super
    end
  end

  describe ".create_class" do
    it "builds a class" do
      klass = ROM::Command.create_class(type: ROM::Memory::Commands::Create)

      expect(klass.name).to eql("ROM::Memory::Commands::Create")
    end

    it "builds a class and yields it" do
      klass = ROM::Command.create_class(type: ROM::Memory::Commands::Create) do |k|
        k.config.result = :one
        k
      end

      expect(klass.name).to eql("ROM::Memory::Commands::Create")
      expect(klass.config.result).to be(:one)
    end
  end

  describe ".build" do
    it "returns create command when type is set to :create" do
      klass = Class.new(ROM::Commands::Create[:memory]) do
        config.component.relation = :users
      end

      command = klass.build(users_relation)

      expect(command).to be_kind_of(ROM::Memory::Commands::Create)
    end

    it "returns update command when type is set to :update" do
      klass = Class.new(ROM::Commands::Update[:memory]) do
        config.component.relation = :users
      end

      command = klass.build(users_relation)

      expect(command).to be_kind_of(ROM::Memory::Commands::Update)
    end

    it "returns delete command when type is set to :delete" do
      klass = Class.new(ROM::Commands::Delete[:memory]) do
        config.component.relation = :users
      end

      command = klass.build(users_relation)

      expect(command).to be_kind_of(ROM::Memory::Commands::Delete)
    end
  end

  describe "#>>" do
    let(:users) { double("users", schema: nil) }
    let(:tasks) { double("tasks", schema: nil) }
    let(:logs) { double("logs", schema: nil) }

    it "composes two commands" do
      user_input = {name: "Jane"}
      user_tuple = {user_id: 1, name: "Jane"}

      task_input = {title: "Task One"}
      task_tuple = {user_id: 1, title: "Task One"}

      create_user = Class.new(ROM::Commands::Create) {
        def execute(user_input)
          relation.insert(user_input)
        end
      }.build(users)

      create_task = Class.new(ROM::Commands::Create) {
        before :associate

        def associate(task_input, user_tuple)
          task_input.merge(user_id: user_tuple[:user_id])
        end

        def execute(task_input)
          relation.insert(task_input)
        end
      }.build(tasks)

      create_log = Class.new(ROM::Commands::Create) {
        config.result = :one

        def execute(task_tuple)
          relation << task_tuple
        end
      }.build(logs)

      command = create_user.curry(user_input)
      command >>= create_task.curry(task_input)
      command >>= create_log

      expect(users).to receive(:insert).with(user_input).and_return(user_tuple)
      expect(tasks).to receive(:insert).with(task_tuple).and_return(task_tuple)
      expect(logs).to receive(:<<).with(task_tuple).and_return([task_tuple])

      expect(command.call).to eql(task_tuple)
    end

    it "forwards methods to the left" do
      user_input = {name: "Jane"}
      user_tuple = {user_id: 1, name: "Jane"}

      create_user = Class.new(ROM::Commands::Create) {
        def execute(user_input)
          relation.insert(user_input)
        end
      }.build(users)

      command = create_user >> proc {}

      expect(users).to receive(:insert).with(user_input).and_return(user_tuple)

      command.curry(user_input).call
    end

    it "short-circuits pipeline when left-side result is empty" do
      command = Class.new(ROM::Commands::Update) do
        config.result = :one

        def execute(*)
          []
        end
      end.build(users) >> -> result { result.map(&:to_a) }

      expect(command.call("foo")).to be(nil)

      command = Class.new(ROM::Commands::Update) do
        config.result = :many

        def execute(*)
          []
        end
      end.build(users) >> -> result { result.map(&:to_a) }

      expect(command.call("foo")).to be(ROM::EMPTY_ARRAY)
    end
  end
end
