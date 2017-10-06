shared_examples_for 'materializable relation' do
  describe '#each' do
    it 'yields objects' do
      count = relation.to_a.size
      result = []

      relation.each do |object|
        result << object
      end

      expect(result.count).to eql(count)
    end

    it 'returns enumerator when block is not provided' do
      expect(relation.each.to_a).to eql(relation.to_a)
    end
  end

  describe '#map' do
    it 'yields objects' do
      count = relation.to_a.size
      result = []

      relation.map do |object|
        result << object
      end

      expect(result.count).to eql(count)
    end

    it 'returns enumerator when block is not provided' do
      expect(relation.map.to_a).to eql(relation.to_a)
    end
  end

  describe '#one' do
    it 'returns one tuple' do
      expect(relation.one).to be_instance_of(Hash)
    end
  end

  describe '#first' do
    it 'returns first tuple' do
      expect(relation.first).to be_instance_of(Hash)
    end
  end

  describe '#call' do
    it 'materializes relation' do
      expect(relation.call).to be_instance_of(ROM::Relation::Loaded)
    end
  end
end
