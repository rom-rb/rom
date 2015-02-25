require 'spec_helper'

describe ROM::Relation::Composite do
  include_context 'users and tasks'

  let(:users) { rom.relation(:users) }

  let(:name_list) { proc { |r| r.map { |t| t[:name] } } }
  let(:upcaser) { proc { |r| r.map(&:upcase) } }

  before do
    setup.relation(:users) do
      def by_name(name)
        restrict(name: name)
      end

      def sorted(other)
        other.sort_by { |t| t[:name] }
      end
    end
  end

  describe '#call' do
    it 'sends a relation through mappers' do
      relation = users >> name_list >> upcaser
      loaded = relation.call

      expect(loaded.source).to eql(users.relation)
      expect(loaded).to match_array(%w(JANE JOE))
    end

    it 'sends a relation through another relation' do
      relation = users >> users.sorted
      loaded = relation.call

      expect(loaded.source).to eql(users.relation)
      expect(loaded).to match_array([
        { name: 'Jane', email: 'jane@doe.org' },
        { name: 'Joe', email: 'joe@doe.org' }
      ])
    end
  end

  describe '#each' do
    let(:relation) { users >> name_list >> upcaser }

    it 'calls and iterates' do
      result = []
      relation.each { |object| result << object }
      expect(result).to match_array(%w(JANE JOE))
    end

    it 'returns enumerator if block is not provided' do
      expect(relation.each.to_a).to match_array(%w(JANE JOE))
    end
  end

  describe '#first' do
    let(:relation) { users >> name_list >> upcaser }

    it 'calls and returns the first object' do
      expect(relation.first).to eql('JOE')
    end
  end
end
