require 'rom/associations/many_to_one'

RSpec.describe ROM::Associations::ManyToOne do
  subject(:assoc) do
    build_assoc(:many_to_one, :users, :groups, as: :group)
  end

  let(:relations) do
    { users: users, groups: groups }
  end

  let(:users) do
    ROM::Relation.new([], name: ROM::Relation::Name[:users])
  end

  let(:groups) do
    ROM::Relation.new([], name: ROM::Relation::Name[:groups])
  end

  describe '#wrap' do
    it 'returns a wrap node relation' do
      wrap_node = assoc.wrap

      expect(wrap_node.name).to be(ROM::Relation::Name[:groups].as(:group))
    end
  end

  describe '#node' do
    it 'returns a graph node relation' do
      graph_node = assoc.node

      expect(graph_node.name).to be(ROM::Relation::Name[:groups].as(:group))
    end
  end
end
