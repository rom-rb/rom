# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Mappers / Symbolizing atributes" do
  include_context "container"

  before do
    configuration.relation(:users)
    configuration.relation(:tasks)
  end

  it "automatically maps all attributes using top-level settings" do
    module Test
      class UserMapper < ROM::Mapper
        relation :users

        symbolize_keys true
        prefix "user"

        attribute :id

        wrap :details, prefix: "first" do
          attribute :name
        end

        wrap :contact, prefix: false do
          attribute :email
        end
      end
    end

    configuration.register_mapper(Test::UserMapper)

    container.relations.users << {
      "user_id" => 123,
      "first_name" => "Jane",
      "email" => "jane@doe.org"
    }

    jane = container.relations[:users].map_with(:users).first

    expect(jane).to eql(
      id: 123, details: {name: "Jane"}, contact: {email: "jane@doe.org"}
    )
  end

  it "automatically maps all attributes using settings for wrap block" do
    module Test
      class TaskMapper < ROM::Mapper
        relation :tasks
        symbolize_keys true

        attribute :title

        wrap :details, prefix: "task" do
          attribute :priority
          attribute :description
        end
      end
    end

    configuration.register_mapper(Test::TaskMapper)

    container.relations.tasks << {
      "title" => "Task One",
      "task_priority" => 1,
      "task_description" => "It is a task"
    }

    task = container.relations[:tasks].map_with(:tasks).first

    expect(task).to eql(
      title: "Task One",
      details: {priority: 1, description: "It is a task"}
    )
  end
end
