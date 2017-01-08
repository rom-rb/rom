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
end
