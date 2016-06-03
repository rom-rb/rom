RSpec.describe ROM::Changeset do
  subject(:changeset) { ROM::Changeset.new(relation, data) }

  let(:jane) { { id: 2, name: "Jane" } }
  let(:relation) { double(ROM::Relation, primary_key: :id) }

  describe '#diff' do
    it 'returns a hash with changes' do
      expect(relation).to receive(:fetch).with(2).and_return(jane)

      changeset = ROM::Changeset.new(relation, id: 2, name: "Jane Doe")

      expect(changeset.diff).to eql(name: "Jane Doe")
    end
  end

  describe '#diff?' do
    it 'returns true when data differs from the original tuple' do
      expect(relation).to receive(:fetch).with(2).and_return(jane)

      changeset = ROM::Changeset.new(relation, id: 2, name: "Jane Doe")

      expect(changeset).to be_diff
    end

    it 'returns false when data are equal to the original tuple' do
      expect(relation).to receive(:fetch).with(2).and_return(jane)

      changeset = ROM::Changeset.new(relation, id: 2, name: "Jane")

      expect(changeset).to_not be_diff
    end
  end
end
