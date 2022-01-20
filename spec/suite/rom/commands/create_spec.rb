# frozen_string_literal: true

require "spec_helper"
require "dry-struct"

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

  it "inserts user on successful validation" do
    result = users[:create].call(name: "Piotr", email: "piotr@solnic.eu")

    expect(result).to eql(name: "Piotr", email: "piotr@solnic.eu")
  end

  it "inserts user and associated task when things go well" do
    result = users[:create].curry(name: "Piotr", email: "piotr@solnic.eu")
              .>> tasks[:create].curry(title: "Finish command-api")

    expect(result.call).to eql(name: "Piotr", title: "Finish command-api")
  end

  describe '"result" option' do
    it "returns a single tuple when set to :one" do
      configuration.commands(:users) do
        define(:create_one, type: :create) do
          config.result = :one
        end
      end

      tuple = {name: "Piotr", email: "piotr@solnic.eu"}

      result = users[:create_one].call(tuple)

      expect(result).to eql(tuple)
    end

    it "allows only valid result types" do
      expect {
        configuration.commands(:users) do
          define(:create_one, type: :create) do
            config.result = :invalid_type
          end
        end
        container.commands[:users][:create_one]
      }.to raise_error(Dry::Types::ConstraintError)
    end
  end
end
