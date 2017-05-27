require 'rom/relation/name'

RSpec.describe ROM::Relation::Name do
  describe '.[]' do
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

  describe '#inspect' do
    it 'provides relation name' do
      name = ROM::Relation::Name.new(:users)
      expect(name.inspect).to eql("ROM::Relation::Name(users)")
    end

    it 'provides dataset and relation names' do
      name = ROM::Relation::Name.new(:authors, :users)
      expect(name.inspect).to eql("ROM::Relation::Name(authors on users)")
    end
  end

  describe '#with' do
    it 'returns a new name with the same dataset but for a different relation name' do
      name = ROM::Relation::Name[:users]
      expect(name.with(:people)).to be(ROM::Relation::Name[:people, :users])
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
