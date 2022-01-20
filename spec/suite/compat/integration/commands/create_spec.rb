# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Commands / Create" do
  include_context "container"
  include_context "users and tasks"

  let(:users) { container.commands[:users] }
  let(:tasks) { container.commands[:tasks] }

  before do
    configuration.relation(:users)
    configuration.relation(:tasks)

    class Test::CreateUser < ROM::Commands::Create[:memory]
      config.component.id = :create
      config.component.namespace = :users
      config.component.relation = :users
      config.result = :one
    end

    class Test::CreateTask < ROM::Commands::Create[:memory]
      config.component.id = :create
      config.component.namespace = :tasks
      config.component.relation = :tasks
      config.result = :one

      before :associate

      def associate(task, user)
        task.merge(name: user.to_h[:name])
      end
    end

    Test::User = Class.new(Dry::Struct) do
      attribute :name, Types::String
      attribute :email, Types::String
    end

    Test::Task = Class.new(Dry::Struct) do
      attribute :name, Types::String
      attribute :title, Types::String
    end

    class Test::UserMapper < ROM::Mapper
      config.component.id = :user_entity
      config.component.namespace = :users
      config.component.relation = :users

      model Test::User

      attribute :name
      attribute :email
    end

    class Test::TaskMapper < ROM::Mapper
      config.component.id = :task_entity
      config.component.namespace = :tasks
      config.component.relation = :tasks

      model Test::Task

      attribute :name
      attribute :title
    end

    configuration.register_command(Test::CreateUser, Test::CreateTask)
    configuration.register_mapper(Test::UserMapper, Test::TaskMapper)
  end

  describe "sending result through a mapper" do
    let(:attributes) do
      {name: "Jane", email: "jane@doe.org"}
    end

    it "uses registered mapper to process the result for :one result" do
      command = container.commands[:users].map_with(:user_entity).create
      result = command[attributes]

      expect(result).to eql(Test::User.new(attributes))
    end

    it "with two composed commands respects the :result option" do
      mapper_input = nil

      mapper = proc do |tuples|
        mapper_input = tuples
      end

      left = container.commands[:users].map_with(:user_entity).create.curry(
        name: "Jane", email: "jane@doe.org"
      )

      right = container.commands[:tasks].map_with(:task_entity).create.curry(
        title: "Jane task"
      )

      command = left >> right >> mapper

      result = command.call

      task = Test::Task.new(name: "Jane", title: "Jane task")

      expect(mapper_input).to eql([task])
      expect(result).to eql(task)
    end

    it "uses registered mapper to process the result for :many results" do
      configuration.commands(:users) do
        define(:create_many, type: :create)
      end

      command = container.commands[:users].map_with(:user_entity).create_many
      result = command[attributes]

      expect(result).to eql([Test::User.new(attributes)])
    end
  end
end
