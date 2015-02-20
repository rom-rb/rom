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
      expect(relation['Jane'].to_a).to eql(rom.relations.users.by_name('Jane').to_a)
    end

    it 'returns relation' do
      expect(users.call.to_a).to eql(rom.relations.users.to_a)
    end

    describe 'using mappers' do
      subject(:users) { rom.relations.users.to_lazy(mappers: mappers) }

      let(:name_list) { proc { |r| r.map { |t| t[:name] } } }
      let(:upcaser) { proc { |r| r.map(&:upcase) } }
      let(:mappers) { { name_list: name_list, upcaser: upcaser } }

      it 'sends relation through mappers' do
        relation = users.map_with(:name_list, :upcaser).by_name('Jane')

        expect(relation.call.to_a).to eql(['JANE'])
      end
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
