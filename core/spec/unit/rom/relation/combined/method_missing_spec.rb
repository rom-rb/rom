RSpec.describe ROM::Relation::Combined, '#method_missing' do
  subject(:relation) do
    ROM::Relation::Combined.new(users, [tasks])
  end

  let(:users) do
    Class.new(ROM::Relation) do
      def add_node(node)
        ROM::Relation::Combined.new(self, [node])
      end
    end.new([])
  end

  let(:tasks) do
    Class.new(ROM::Relation).new([], name: ROM::Relation::Name[:tasks])
  end

  let(:posts) do
    Class.new(ROM::Relation).new([], name: ROM::Relation::Name[:posts])
  end

  describe 'forwards to the root' do
    context 'when return value is another combined relation' do
      it 'merges nodes' do
        result = relation.add_node(posts)

        expect(result).to be_instance_of(ROM::Relation::Combined)
        expect(result.root).to be(users)
        expect(result.nodes).to eql([tasks, posts])
      end
    end
  end
end
