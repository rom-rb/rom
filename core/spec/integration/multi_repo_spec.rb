require 'spec_helper'
require 'rom/memory'

RSpec.describe 'Using in-memory gateways for cross-gateway access' do
  let(:configuration) do
    ROM::Configuration.new(left: :memory, right: :memory, main: :memory)
  end

  let(:container) { ROM.container(configuration) }
  let(:gateways) { container.gateways }

  it 'works' do
    configuration.relation(:users, gateway: :left) do
      def by_name(name)
        restrict(name: name)
      end
    end

    configuration.relation(:tasks, gateway: :right)

    configuration.relation(:users_and_tasks, gateway: :main) do
      def by_user(name)
        join(users.by_name(name), tasks)
      end
    end

    configuration.mappers do
      define(:users_and_tasks) do
        group tasks: [:title]
      end
    end

    gateways[:left][:users] << { user_id: 1, name: 'Joe' }
    gateways[:left][:users] << { user_id: 2, name: 'Jane' }
    gateways[:right][:tasks] << { user_id: 1, title: 'Have fun' }
    gateways[:right][:tasks] << { user_id: 2, title: 'Have fun' }

    user_and_tasks = container.relations[:users_and_tasks]
      .by_user('Jane')
      .map_with(:users_and_tasks)

    expect(user_and_tasks).to match_array([
      { user_id: 2, name: 'Jane', tasks: [{ title: 'Have fun' }] }
    ])
  end
end
