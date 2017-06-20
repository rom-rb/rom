require 'rom/associations/name'

RSpec.describe ROM::Associations::Name do
  describe '.[]' do
    it 'returns a name object from a relation name' do
      rel_name = ROM::Relation::Name[:users]
      assoc_name = ROM::Associations::Name[rel_name]

      expect(assoc_name).to eql(ROM::Associations::Name.new(rel_name, :users))
    end

    it 'returns a name object from a relation and a dataset symbols' do
      rel_name = ROM::Relation::Name[:users, :people]
      assoc_name = ROM::Associations::Name[:users, :people]

      expect(assoc_name).to eql(ROM::Associations::Name.new(rel_name, :people))
    end

    it 'returns a name object from a relation and a dataset symbols and an alias' do
      rel_name = ROM::Relation::Name[:users, :people]
      assoc_name = ROM::Associations::Name[:users, :people, :author]

      expect(assoc_name).to eql(ROM::Associations::Name.new(rel_name, :author))
    end

    it 'caches names' do
      name = ROM::Associations::Name[:users]

      expect(name).to be(ROM::Associations::Name[:users])

      name = ROM::Associations::Name[:users, :people]

      expect(name).to be(ROM::Associations::Name[:users, :people])

      name = ROM::Associations::Name[:users, :people, :author]

      expect(name).to be(ROM::Associations::Name[:users, :people, :author])
    end
  end

  describe '#aliased?' do
    it 'returns true if a name has an alias' do
      expect(ROM::Associations::Name[:users, :people, :author]).to be_aliased
    end

    it 'returns false if a name has no alias' do
      expect(ROM::Associations::Name[:users, :people]).to_not be_aliased
    end
  end

  describe '#inspect' do
    it 'includes info about the relation name' do
      expect(ROM::Associations::Name[:users].inspect).to eql(
        "ROM::Associations::Name(users)"
      )
    end

    it 'includes info about the relation name and its dataset' do
      expect(ROM::Associations::Name[:users, :people].inspect).to eql(
        "ROM::Associations::Name(users on people)"
      )
    end

    it 'includes info about the relation name, its dataset and alias' do
      expect(ROM::Associations::Name[:users, :people, :author].inspect).to eql(
        "ROM::Associations::Name(users on people as author)"
      )
    end
  end
end
