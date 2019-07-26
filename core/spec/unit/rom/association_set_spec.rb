# frozen_string_literal: true

RSpec.describe ROM::AssociationSet do
  describe '#[]' do
    let(:users) { double(:users, aliased?: false) }
    let(:posts) { double(:posts, aliased?: true, as: :post, name: :posts) }
    let(:set) { ROM::AssociationSet.new(users: users, post: posts) }

    it 'fetches association' do
      expect(set[:users]).to be users
    end

    it 'fetches association by alias' do
      expect(set[:post]).to be posts
    end

    it 'fetches association by canonical name' do
      expect(set[:posts]).to be posts
    end

    it 'throws exception on missing association' do
      expect { set[:labels] }.to raise_error(
        ROM::ElementNotFoundError,
        ":labels doesn't exist in ROM::AssociationSet registry"
      )
    end
  end
end
