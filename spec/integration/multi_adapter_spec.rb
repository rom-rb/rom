RSpec.describe 'Repository with multi-adapters configuration' do
  let(:configuration) {
    ROM::Configuration.new(default: [:sql, DB_URI], memory: [:memory])
  }

  let(:sql_conn) { configuration.gateways[:default].connection }

  let(:rom) { ROM.container(configuration) }

  let(:users) { rom.relation(:sql_users) }
  let(:tasks) { rom.relation(:memory_tasks) }

  let(:repo) { Test::Repository.new(rom) }

  before do
    [:tags, :tasks, :posts, :users, :posts_labels, :labels, :books,
     :reactions, :messages].each { |table| sql_conn.drop_table?(table) }

    sql_conn.create_table :users do
      primary_key :id
      column :name, String
    end

    module Test
      class Users < ROM::Relation[:sql]
        gateway :default
        schema(:users, infer: true)
        register_as :sql_users
      end

      class Tasks < ROM::Relation[:memory]
        schema(:tasks) do
          attribute :user_id, ROM::Types::Int
          attribute :title, ROM::Types::String
        end

        register_as :memory_tasks
        gateway :memory

        use :key_inference

        view(:base, [:user_id, :title]) do
          self
        end

        def for_users(users)
          restrict(user_id: users.pluck(:id))
        end
      end

      class Repository < ROM::Repository[:sql_users]
        relations :memory_tasks

        def users_with_tasks(id)
          aggregate(many: { tasks: memory_tasks }).where(id: id)
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
  end
end
