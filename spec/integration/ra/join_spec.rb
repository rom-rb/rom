require "spec_helper"

describe 'Join operation' do
  include_context 'users and tasks'

  specify 'defining a joined relation' do
    setup.relation(:users) do
      def with_tasks
        in_memory { join(tasks) }
      end
    end

    users = rom.relations.users

    expect(users.with_tasks.to_a).to eql(
      [
        { name: 'Joe', email: 'joe@doe.org', title: 'be nice', priority: 1 },
        { name: 'Joe', email: 'joe@doe.org', title: 'sleep well', priority: 2 },
        { name: 'Jane', email: 'jane@doe.org', title: 'be cool', priority: 2 }
      ]
    )
  end

end
