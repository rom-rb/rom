RSpec.describe 'Repository with multi-adapters setup' do
  include_context 'database'

  let(:rom) { ROM.env }

  let(:users) { rom.relation(:users) }
  let(:tasks) { rom.relation(:tasks) }

  let(:repo) { Test::Repository.new(rom) }

  before do
    ROM.setup( default: [:sql, 'postgres://localhost/rom'], memory: [:memory])

    module Test
      class Users < ROM::Relation[:sql]
      end

      class Tasks < ROM::Relation[:memory]
        use :view

        view(:for_users, [:user_id, :title]) do |users|
          restrict(user_id: users.map { |u| u[:id] })
        end
      end

      class Repository < ROM::Repository::Base
        relations :users, :tasks

        def users_with_tasks
          users.combine_children(many: tasks)
        end
      end
    end

    ROM.finalize

    user_id = users.insert(name: 'Jane')
    tasks.insert(user_id: user_id, title: 'Jane Task')
  end

  specify 'ᕕ⁞ ᵒ̌ 〜 ᵒ̌ ⁞ᕗ' do
    user = repo.users_with_tasks.one

    expect(user.name).to eql('Jane')

    expect(user.tasks[0].user_id).to eql(user.id)
    expect(user.tasks[0].title).to eql('Jane Task')
  end
end
