require 'spec_helper'

describe ROM::Relation::Lazy do
  include_context 'users and tasks'

  let(:users) { rom.relations.users.to_lazy }
  let(:tasks) { rom.relations.tasks.to_lazy }

  before do
    setup.relation(:users) do
      def by_name(name)
        restrict(name: name)
      end
    end

    setup.relation(:tasks) do
      def for_users(users)
        names = users.map { |u| u[:name] }
        restrict { |t| names.include?(t[:name]) }
      end
    end
  end

  describe '#call' do
    it 'auto-curries' do
      relation = users.by_name

      expect(relation.name).to eql(:by_name)
      expect(relation['Jane'].call).to eql(rom.relations.users.by_name('Jane'))
    end

    it 'returns relation' do
      expect(users.call).to eql(rom.relations.users)
    end
  end

  describe '#>>' do
    it 'composes two relations' do
      other = users.by_name('Jane') >> tasks.for_users

      expect(other.to_a).to eql([
        [{ name: 'Jane', email: 'jane@doe.org' }],
        [{ name: 'Jane', title: 'be cool', priority: 2 }]
      ])
    end
  end
end
