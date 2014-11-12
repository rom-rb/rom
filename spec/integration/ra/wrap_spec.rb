require 'spec_helper'

describe 'Wrap operation' do
  include_context 'users and tasks'

  specify 'defining a grouped relation' do
    rom.relations do
      register(:users) do

        def with_task
          ROM::RA.wrap(natural_join(tasks), task: [:title, :priority])
        end

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
