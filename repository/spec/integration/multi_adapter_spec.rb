# coding: utf-8

RSpec.describe 'Repository with multi-adapters configuration' do
  let(:configuration) {
    ROM::Configuration.new(default: [:sql, DB_URI], memory: [:memory])
  }

  let(:sql_conn) { configuration.gateways[:default].connection }

  let(:rom) { ROM.container(configuration) }

  let(:users) { rom.relations[:sql_users] }
  let(:tasks) { rom.relations[:memory_tasks] }

  let(:repo) { Test::Repository.new(rom) }

  before do
    [:tags, :tasks, :books, :posts_labels, :posts, :users, :labels,
     :reactions, :messages].each { |table| sql_conn.drop_table?(table) }

    sql_conn.create_table :users do
      primary_key :id
      column :name, String
    end

    module Test
      class Users < ROM::Relation[:sql]
        gateway :default

        schema(:users, as: :sql_users, infer: true) do
          associations do
            has_many :memory_tasks, as: :tasks, view: :for_users, override: true
          end
        end

        def for_tasks(assoc, tasks)
          where(id: tasks.pluck(:user_id))
        end
      end

      class Tasks < ROM::Relation[:memory]
        gateway :memory

        schema(:tasks, as: :memory_tasks) do
          attribute :user_id, ROM::Types::Integer.meta(foreign_key: true, target: :sql_users)
          attribute :title, ROM::Types::String

          associations do
            belongs_to :sql_users, as: :user, view: :for_tasks, override: true
          end
        end

        def for_users(assoc, users)
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

    configuration.register_relation(Test::Users)
    configuration.register_relation(Test::Tasks)

    user_id = configuration.gateways[:default].dataset(:users).insert(name: 'Jane')
    configuration.gateways[:memory].dataset(:tasks).insert(user_id: user_id, title: 'Jane Task')
  end

  specify 'ᕕ⁞ ᵒ̌ 〜 ᵒ̌ ⁞ᕗ' do
    user = repo.users_with_tasks(users.last[:id]).first

    expect(user.name).to eql('Jane')

    expect(user.tasks[0].user_id).to eql(user.id)
    expect(user.tasks[0].title).to eql('Jane Task')

    task = repo.tasks_with_users(tasks.first[:id]).first

    expect(task.title).to eql('Jane Task')
    expect(task.user.name).to eql('Jane')
  end
end
