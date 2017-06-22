require 'rom/associations/one_to_many'

RSpec.describe ROM::Associations::OneToMany do
  subject(:assoc) do
    build_assoc(:one_to_many, :groups, :users, options.merge(as: :users))
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
