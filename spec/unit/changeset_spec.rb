RSpec.describe ROM::Changeset do
  let(:jane) { { id: 2, name: "Jane" } }
  let(:relation) { double(ROM::Relation, primary_key: :id) }

  describe '#diff' do
    it 'returns a hash with changes' do
      expect(relation).to receive(:fetch).with(2).and_return(jane)

      changeset = ROM::Changeset::Update.new(relation, { name: "Jane Doe" }, primary_key: 2)

      expect(changeset.diff).to eql(name: "Jane Doe")
    end
  end

  describe '#diff?' do
    it 'returns true when data differs from the original tuple' do
      expect(relation).to receive(:fetch).with(2).and_return(jane)

      changeset = ROM::Changeset::Update.new(relation, { name: "Jane Doe" }, primary_key: 2)

      expect(changeset).to be_diff
    end

    it 'returns false when data are equal to the original tuple' do
      expect(relation).to receive(:fetch).with(2).and_return(jane)

      changeset = ROM::Changeset::Update.new(relation, { name: "Jane" }, primary_key: 2)

      expect(changeset).to_not be_diff
    end
  end

  describe 'quacks like a hash' do
    subject(:changeset) { ROM::Changeset::Create.new(relation, data) }

    let(:data) { instance_double(Hash) }

    it 'delegates to its data hash' do
      expect(data).to receive(:[]).with(:name).and_return('Jane')

      expect(changeset[:name]).to eql('Jane')
    end

    it 'maintains its own type' do
      expect(data).to receive(:merge).with(foo: 'bar').and_return(foo: 'bar')

      new_changeset = changeset.merge(foo: 'bar')

      expect(new_changeset).to be_instance_of(ROM::Changeset::Create)
      expect(new_changeset.options).to eql(changeset.options)
      expect(new_changeset.to_h).to eql(foo: 'bar')
    end

    it 'raises NoMethodError when an unknown message was sent' do
      expect { changeset.not_here }.to raise_error(NoMethodError, /not_here/)
    end
  end
end
