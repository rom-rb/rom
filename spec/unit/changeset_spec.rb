RSpec.describe ROM::Changeset do
  let(:jane) { { id: 2, name: "Jane" } }
  let(:relation) { double(ROM::Relation, primary_key: :id) }

  describe 'builder function' do
    it 'returns a create changeset for new data' do
      expect(ROM.Changeset(relation, name: "Jane")).to be_create
    end

    it 'returns an update changeset for persisted data' do
      expect(ROM.Changeset(relation, jane)).to be_update
    end
  end

  describe '#diff' do
    it 'returns a hash with changes' do
      expect(relation).to receive(:fetch).with(2).and_return(jane)

      changeset = ROM::Changeset(relation, id: 2, name: "Jane Doe")

      expect(changeset.diff).to eql(name: "Jane Doe")
    end
  end

  describe '#diff?' do
    it 'returns true when data differs from the original tuple' do
      expect(relation).to receive(:fetch).with(2).and_return(jane)

      changeset = ROM::Changeset(relation, id: 2, name: "Jane Doe")

      expect(changeset).to be_diff
    end

    it 'returns false when data are equal to the original tuple' do
      expect(relation).to receive(:fetch).with(2).and_return(jane)

      changeset = ROM::Changeset(relation, id: 2, name: "Jane")

      expect(changeset).to_not be_diff
    end
  end
end
