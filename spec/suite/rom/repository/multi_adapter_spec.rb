# frozen_string_literal: true

require "rom/repository"

RSpec.describe "Repository with multi-adapters configuration" do
  include_context "repository / db_uri"

  let(:runtime) {
    ROM::Runtime.new(default: [:sql, db_uri], memory: [:memory])
  }

  let(:sql_conn) { resolver.gateways[:default].connection }

  let(:resolver) { runtime.finalize }

  let(:users) { resolver.relations[:sql_users] }
  let(:tasks) { resolver.relations[:memory_tasks] }

  let(:repo) { Test::Repository.new(resolver) }

  before do
    %i[tags tasks books posts_labels posts users labels
       reactions messages].each { |table| sql_conn.drop_table?(table) }

    sql_conn.create_table :users do
      primary_key :id
      column :name, String
    end

    module Test
      class Users < ROM::Relation[:sql]
        config.component.id = :sql_users
        config.component.gateway = :default
        config.schema.infer = true

        schema(:users)

        associations do
          has_many :memory_tasks, as: :tasks, view: :for_users, override: true
        end

        def for_tasks(_assoc, tasks)
          where(id: tasks.pluck(:user_id))
        end
      end

      class Tasks < ROM::Relation[:memory]
        config.component.id = :memory_tasks
        config.component.dataset = :tasks
        config.component.gateway = :memory

        schema do
          attribute :user_id, ROM::Types::Integer.meta(foreign_key: true, target: :sql_users)
          attribute :title, ROM::Types::String
        end

        associations do
          belongs_to :sql_users, as: :user, view: :for_tasks, override: true
        end

        def for_users(_assoc, users)
          restrict(user_id: users.pluck(:id))
        end
      end

      class Repository < ROM::Repository[:sql_users]
        def users_with_tasks(id)
          sql_users.combine(:tasks).where(id: id)
        end

        def tasks_with_users(id)
          memory_tasks.combine(:user).restrict(id: id)
        end
      end
    end

    runtime.register_relation(Test::Users)
    runtime.register_relation(Test::Tasks)

    user_id = resolver.gateways[:default].dataset(:users).insert(name: "Jane")
    resolver.gateways[:memory].dataset(:tasks).insert(user_id: user_id, title: "Jane Task")
  end

  specify "ᕕ⁞ ᵒ̌ 〜 ᵒ̌ ⁞ᕗ" do
    user = repo.users_with_tasks(users.last[:id]).first

    expect(user.name).to eql("Jane")

    expect(user.tasks[0].user_id).to eql(user.id)
    expect(user.tasks[0].title).to eql("Jane Task")

    task = repo.tasks_with_users(tasks.first[:id]).first

    expect(task.title).to eql("Jane Task")
    expect(task.user.name).to eql("Jane")
  end
end
