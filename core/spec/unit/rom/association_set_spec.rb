RSpec.describe ROM::AssociationSet do
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
        ROM::ElementNotFoundError,
        ":labels doesn't exist in ROM::AssociationSet registry"
      )
    end
  end
end
