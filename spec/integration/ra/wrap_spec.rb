require 'spec_helper'

describe 'Wrap operation' do
  include_context 'users and tasks'

  specify 'defining a wrapped relation' do
    setup.relation(:users) do
      def with_task
        in_memory { wrap(join(tasks), task: [:title, :priority]) }
      end
    end

    users = rom.relations.users

    expect(users.with_task.to_a).to eql(
      [
        {
          name: "Joe",
          email: "joe@doe.org",
          task: { title: "be nice", priority: 1 }
        },
        {
          name: "Joe",
          email: "joe@doe.org",
          task: { title: "sleep well", priority: 2 }
        },
        {
          name: "Jane",
          email: "jane@doe.org",
          task: { title: "be cool", priority: 2 }
        }
      ]
    )
  end
end
