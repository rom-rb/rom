RSpec.describe 'Repository with multi-adapters setup' do
  include_context 'database'

  let(:setup) {
    ROM.setup(default: [:sql, 'postgres://localhost/rom'], memory: [:memory])
  }

  let(:users) { rom.relation(:sql_users) }
  let(:tasks) { rom.relation(:memory_tasks) }

  let(:repo) { Test::Repository.new(rom) }

  before do
    module Test
      class Users < ROM::Relation[:sql]
        dataset :users
        register_as :sql_users
        gateway :default
      end

      class Tasks < ROM::Relation[:memory]
        dataset :tasks
        register_as :memory_tasks
        gateway :memory

        use :view
        use :key_inference

        view(:base, [:user_id, :title]) do
          project(:user_id, :title)
        end

        def for_users(users)
          restrict(user_id: users.map { |u| u[:id] })
        end
      end

      class Repository < ROM::Repository::Base
        relations :sql_users, :memory_tasks

        def users_with_tasks(id)
          sql_users.where(id: id).combine_children(many: { tasks: memory_tasks })
        end
      end
    end

    user_id = setup.gateways[:default].dataset(:users).insert(name: 'Jane')
    setup.gateways[:memory].dataset(:tasks).insert(user_id: user_id, title: 'Jane Task')
  end

  specify 'ᕕ⁞ ᵒ̌ 〜 ᵒ̌ ⁞ᕗ' do
    user = repo.users_with_tasks(users.last[:id]).first

    expect(user.name).to eql('Jane')

    expect(user.tasks[0].user_id).to eql(user.id)
    expect(user.tasks[0].title).to eql('Jane Task')
  end
end
