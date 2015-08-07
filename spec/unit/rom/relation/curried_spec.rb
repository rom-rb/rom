RSpec.describe ROM::Relation::Curried do
  include_context 'users and tasks'

  let(:users) { rom.relations.users }

  before do
    setup.relation(:users) do
      def by_name(name)
        restrict(name: name)
      end
    end
  end

  describe '#call' do
    let(:relation) { users.by_name.('Jane') }

    it 'materializes a relation' do
      expect(relation).to match_array([
        name: 'Jane', email: 'jane@doe.org'
      ])
    end

    it 'returns a loaded relation' do
      expect(relation.source).to eql(users.by_name('Jane'))
    end
  end
end
