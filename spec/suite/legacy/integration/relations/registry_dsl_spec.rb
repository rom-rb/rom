# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Relation registration DSL" do
  include_context "container"
  include_context "users and tasks"

  it "defines relations with views" do
    configuration.relation(:tasks) do
      def high_priority
        restrict { |tuple| tuple[:priority] < 2 }
      end

      def by_title(title)
        restrict(title: title)
      end
    end

    configuration.relation(:users) do
      def with_tasks
        join(tasks)
      end
    end

    tasks = container.relations.tasks

    expect(tasks.class.name).to eql("ROM::Relations::Tasks")
    expect(tasks.high_priority.inspect).to include("#<ROM::Relations::Tasks")

    expect(tasks.high_priority.by_title("be nice")).to match_array(
      [name: "Joe", title: "be nice", priority: 1]
    )

    expect(tasks.by_title("be cool")).to match_array(
      [name: "Jane", title: "be cool", priority: 2]
    )

    users = container.relations.users

    expect(users.with_tasks).to match_array(
      [{name: "Joe", email: "joe@doe.org", title: "be nice", priority: 1},
       {name: "Joe", email: "joe@doe.org", title: "sleep well", priority: 2},
       {name: "Jane", email: "jane@doe.org", title: "be cool", priority: 2}]
    )
  end
end
