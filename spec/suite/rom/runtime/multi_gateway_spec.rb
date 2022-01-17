# frozen_string_literal: true

require "rom/memory"

RSpec.describe "Using in-memory gateways for cross-gateway access" do
  let(:runtime) { ROM::Runtime.new(left: :memory, right: :memory, main: :memory) }
  let(:resolver) { runtime.finalize }
  let(:gateways) { resolver.gateways }

  it "works" do
    runtime.relation(:users, gateway: :left) do
      def by_name(name)
        restrict(name: name)
      end
    end

    runtime.relation(:tasks, gateway: :right)

    runtime.relation(:users_and_tasks, gateway: :main) do
      def by_user(name)
        join(users.by_name(name), tasks)
      end
    end

    runtime.mappers do
      define(:users_and_tasks) do
        group tasks: [:title]
      end
    end

    resolver.relations[:users]
    resolver.relations[:tasks]

    gateways[:left][:users] << {user_id: 1, name: "Joe"}
    gateways[:left][:users] << {user_id: 2, name: "Jane"}
    gateways[:right][:tasks] << {user_id: 1, title: "Have fun"}
    gateways[:right][:tasks] << {user_id: 2, title: "Have fun"}

    user_and_tasks = resolver.relations[:users_and_tasks]
      .by_user("Jane")
      .map_with(:users_and_tasks)

    expect(user_and_tasks).to match_array([
      {user_id: 2, name: "Jane", tasks: [{title: "Have fun"}]}
    ])
  end
end
