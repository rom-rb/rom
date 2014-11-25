require "spec_helper"

describe 'Join operation' do
  include_context 'users and tasks'

  specify 'defining a joined one-to-many relation' do
    setup.relation(:users) do
      def with_tasks
        in_memory { join(tasks) }
      end
    end

    setup.relation(:tasks)

    users = rom.relations.users

    expect(users.with_tasks.to_a).to eql(
      [
        { name: 'Joe', email: 'joe@doe.org', title: 'be nice', priority: 1 },
        { name: 'Joe', email: 'joe@doe.org', title: 'sleep well', priority: 2 },
        { name: 'Jane', email: 'jane@doe.org', title: 'be cool', priority: 2 }
      ]
    )
  end

  specify 'defining a joined many-to-one relation' do
    setup.relation(:users)

    setup.relation(:tasks) do
      def with_user
        in_memory { join(users) }
      end
    end

    tasks = rom.relations.tasks

    expect(tasks.with_user.to_a).to eql(
      [
        { title: 'be nice', priority: 1, name: 'Joe', email: 'joe@doe.org' },
        { title: 'sleep well', priority: 2, name: 'Joe', email: 'joe@doe.org' },
        { title: 'be cool', priority: 2, name: 'Jane', email: 'jane@doe.org' }
      ]
    )
  end

end
