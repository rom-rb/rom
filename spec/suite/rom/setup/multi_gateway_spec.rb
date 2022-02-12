# frozen_string_literal: true

require "rom/memory"

RSpec.describe "Using in-memory gateways for cross-gateway access" do
  let(:setup) { ROM::Setup.new(left: :memory, right: :memory, main: :memory) }
  let(:registry) { setup.finalize }
  let(:gateways) { registry.gateways }

  it "works" do
    setup.relation(:users, gateway: :left) do
      def by_name(name)
        restrict(name: name)
      end
    end

    setup.relation(:tasks, gateway: :right)

    setup.relation(:users_and_tasks, gateway: :main) do
      def by_user(name)
        join(users.by_name(name), tasks)
      end
    end

    setup.mappers do
      define(:users_and_tasks) do
        group tasks: [:title]
      end
    end

    registry.relations[:users]
    registry.relations[:tasks]

    gateways[:left][:users] << {user_id: 1, name: "Joe"}
    gateways[:left][:users] << {user_id: 2, name: "Jane"}
    gateways[:right][:tasks] << {user_id: 1, title: "Have fun"}
    gateways[:right][:tasks] << {user_id: 2, title: "Have fun"}

    user_and_tasks = registry.relations[:users_and_tasks]
      .by_user("Jane")
      .map_with(:users_and_tasks)

    expect(user_and_tasks).to match_array([
      {user_id: 2, name: "Jane", tasks: [{title: "Have fun"}]}
    ])
  end
end
