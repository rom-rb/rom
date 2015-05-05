require 'spec_helper'

describe ROM::Relation::Graph do
  subject(:graph) { ROM::Relation::Graph.new(users, [tasks.for_users]) }

  include_context 'users and tasks'

  before do
    setup.relation(:users)

    setup.relation(:tasks) do
      def for_users(users)
        self
      end
    end
  end

  let(:users) { rom.relation(:users) }
  let(:tasks) { rom.relation(:tasks) }

  describe '#call' do
    it 'materializes relations' do
      expect(graph.call).to match_array([
        rom.relations.users,
        [rom.relations.tasks]
      ])
    end
  end

  describe '#to_a' do
    it 'coerces to an array' do
      expect(graph).to match_array([
        users.to_a,
        [tasks.for_users(users).to_a]
      ])
    end
  end
end
