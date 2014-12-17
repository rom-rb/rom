require 'spec_helper'

describe 'Relation registration DSL' do
  include_context 'users and tasks'

  it 'allows to expose chainable relations' do
    setup.relation(:tasks) do
      def high_priority
        restrict { |tuple| tuple[:priority] < 2 }
      end

      def by_title(title)
        restrict(title: title)
      end
    end

    setup.relation(:users) do
      include ROM::RA

      def with_tasks
        join(tasks)
      end
    end

    tasks = rom.relations.tasks

    expect(tasks.class.name).to eql("ROM::Relation[Tasks]")
    expect(tasks.high_priority.inspect).to include("#<ROM::Relation[Tasks]")

    expect(tasks.high_priority.by_title("be nice")).to match_array(
      [name: "Joe", title: "be nice", priority: 1]
    )

    expect(tasks.by_title("be cool")).to match_array(
      [name: "Jane", title: "be cool", priority: 2]
    )

    users = rom.relations.users

    expect(users.with_tasks.to_a).to eql(
      [{ name: "Joe", email: "joe@doe.org", title: "be nice", priority: 1 },
       { name: "Joe", email: "joe@doe.org", title: "sleep well", priority: 2 },
       { name: "Jane", email: "jane@doe.org", title: "be cool", priority: 2 }]
    )
  end
end
