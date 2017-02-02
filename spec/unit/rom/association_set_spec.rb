RSpec.describe ROM::AssociationSet do
  describe '#try' do
    it 'returns association when it exists' do
      assoc = spy(:assoc)
      assoc_set = ROM::AssociationSet.new(users: assoc)

      assoc_set.try(:users, &:done)

      expect(assoc).to have_received(:done)

      assoc_set.try(:user, &:done)

      expect(assoc).to have_received(:done)
    end

    it 'returns false when assoc is not found' do
      assoc = spy(:assoc)
      fallback = spy(:fallback)
      assoc_set = ROM::AssociationSet.new({})

      assoc_set.try(:users, &:done) or fallback.done

      expect(assoc).to_not have_received(:done)
      expect(fallback).to have_received(:done)
    end
  end

  describe '#[]' do
    let(:users) { BasicObject.new }
    let(:posts) { BasicObject.new }
    let(:set) { ROM::AssociationSet.new(users: users, post: posts) }

    it 'fetches association' do
      expect(set[:users]).to be users
    end

    it 'tries to fetch under singularized key' do
      expect(set[:post]).to be posts
    end

    it 'throws exception on missing association' do
      expect { set[:labels] }.to raise_error(
        ROM::Registry::ElementNotFoundError,
        ":labels doesn't exist in ROM::AssociationSet registry"
      )
    end
  end
end
