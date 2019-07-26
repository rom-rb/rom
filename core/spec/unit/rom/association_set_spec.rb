# frozen_string_literal: true

RSpec.describe ROM::AssociationSet do
  subject(:set) { ROM::AssociationSet[:projects].new(elements) }

  describe '.[]' do
    it 'builds a class with the provided identifier' do
      klass = ROM::AssociationSet[:users]

      expect(klass.name).to eql('ROM::AssociationSet[:users]')
    end

    it 'caches the class' do
      expect(ROM::AssociationSet[:users]).to be(ROM::AssociationSet[:users])
    end
  end

  describe '#[]' do
    let(:elements) { { users: users, post: posts } }

    let(:users) { double(:users, aliased?: false) }
    let(:posts) { double(:posts, aliased?: true, as: :post, name: :posts) }

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
        ":labels doesn't exist in ROM::AssociationSet[:projects] registry"
      )
    end
  end
end
