RSpec.describe ROM::Relation::Combined do
  subject(:relation) do
    ROM::Relation::Combined.new(users, [])
  end

  let(:users) do
    Class.new(ROM::Relation) do
      def by_name(name)
        self
      end
    end.new([])
  end

  describe '#graph?' do
    it 'returns true' do
      expect(relation).to be_graph
    end

    it 'returns true when curried' do
      expect(relation.by_name).to be_graph
    end
  end
end
