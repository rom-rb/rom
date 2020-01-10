# frozen_string_literal: true

require 'rom/relation/name'

RSpec.describe ROM::Relation::Name do
  describe '.[]' do
    before { ROM::Relation::Name.cache.clear }

    it 'returns a new name from args' do
      expect(ROM::Relation::Name[:users]).to eql(
        ROM::Relation::Name.new(:users)
      )

      expect(ROM::Relation::Name[:authors, :users]).to eql(
        ROM::Relation::Name.new(:authors, :users)
      )
    end

    it 'returns name object when it was passed in as arg' do
      name = ROM::Relation::Name[:users]
      expect(ROM::Relation::Name[name]).to be(name)
    end

    it 'caches name instances' do
      name = ROM::Relation::Name[:users]
      expect(ROM::Relation::Name[:users]).to be(name)
    end
  end

  describe '#eql?' do
    it 'returns true when relation is the same' do
      expect(ROM::Relation::Name.new(:users))
        .to eql(ROM::Relation::Name.new(:users))
    end

    it 'returns false when relation is not the same' do
      expect(ROM::Relation::Name.new(:users))
        .to_not eql(ROM::Relation::Name.new(:tasks))
    end

    it 'returns true when relation and dataset are the same' do
      expect(ROM::Relation::Name.new(:users, :people))
        .to eql(ROM::Relation::Name.new(:users, :people))
    end

    it 'returns false when relation and dataset are not the same' do
      expect(ROM::Relation::Name.new(:users, :people))
        .to_not eql(ROM::Relation::Name.new(:users, :folks))
    end

    it 'returns true when relation, dataset and alias are the same' do
      expect(ROM::Relation::Name.new(:posts, :posts, :published))
        .to eql(ROM::Relation::Name.new(:posts, :posts, :published))
    end

    it 'returns false when relation, dataset and alias are not the same' do
      expect(ROM::Relation::Name.new(:posts, :articles, :published))
        .to_not eql(ROM::Relation::Name.new(:posts, :posts, :deleted))
    end

    it 'returns false when relation and dataset are the same but aliases are different' do
      expect(ROM::Relation::Name.new(:posts, :posts, :published))
        .to_not eql(ROM::Relation::Name.new(:posts, :posts, :deleted))
    end
  end

  describe '#inspect' do
    it 'provides relation name' do
      name = ROM::Relation::Name.new(:users)
      expect(name.inspect).to eql('ROM::Relation::Name(users)')

      name = ROM::Relation::Name.new(:users, :users, :users)
      expect(name.inspect).to eql('ROM::Relation::Name(users)')
    end

    it 'provides dataset and relation names' do
      name = ROM::Relation::Name.new(:authors, :users)
      expect(name.inspect).to eql('ROM::Relation::Name(authors on users)')
    end

    it 'provides dataset, relation and alias names' do
      name = ROM::Relation::Name.new(:authors, :users, :admins)
      expect(name.inspect).to eql('ROM::Relation::Name(authors on users as admins)')
    end
  end

  describe '#as' do
    it 'returns an aliased name' do
      name = ROM::Relation::Name[:users]
      expect(name.as(:people)).to be(ROM::Relation::Name[:users, :users, :people])
    end
  end

  describe '#aliased' do
    let(:name) { ROM::Relation::Name[:users] }

    it 'returns true when name is aliased' do
      expect(name.as(:people)).to be_aliased
    end

    it 'returns true when name is not aliased' do
      expect(name).to_not be_aliased
    end
  end

  describe '#to_sym' do
    it 'returns relation name' do
      expect(ROM::Relation::Name.new(:users).to_sym).to be(:users)
      expect(ROM::Relation::Name.new(:authors, :users).to_sym).to be(:authors)
    end
  end

  describe '#to_s' do
    it 'returns stringified relation name' do
      expect(ROM::Relation::Name.new(:users).to_s).to eql('users')
      expect(ROM::Relation::Name.new(:authors, :users).to_s).to eql('authors on users')
    end
  end
end
