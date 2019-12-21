require 'rom/associations/many_to_one'

RSpec.describe ROM::Associations::ManyToOne do
  subject(:assoc) do
    build_assoc(:many_to_one, :users, :groups, **options, as: :group)
  end

  let(:options) { {} }

  let(:relations) do
    { users: users, groups: groups }
  end

  let(:users) do
    ROM::Relation.new([], name: ROM::Relation::Name[:users])
  end

  let(:groups) do
    ROM::Relation.new([], name: ROM::Relation::Name[:groups])
  end

  describe '#override?' do
    let(:options) { { override: true } }

    it 'returns true when :override was set' do
      expect(assoc).to be_override
    end
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

  describe '#foreign_key' do
    context 'when custom fk is not set' do
      it 'it returns default foreign_key' do
        expect(users).to receive(:foreign_key).with(groups.name).and_return(:group_id)

        expect(assoc.foreign_key).to be(:group_id)
      end
    end

    context 'when custom fk is set' do
      let(:options) { { foreign_key: :GroupId } }

      it 'it returns custom fk' do
        expect(assoc.foreign_key).to be(:GroupId)
      end
    end
  end
end
