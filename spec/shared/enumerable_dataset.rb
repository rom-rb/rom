shared_examples_for "an enumerable dataset" do
  subject(:dataset) { klass.new(data) }

  let(:data) do
    [{ 'name' => 'Jane' }, { 'name' => 'Joe' }]
  end

  describe '#each' do
    it 'yields tuples through row_proc' do
      result = []

      dataset.each do |tuple|
        result << tuple
      end

      expect(result).to match_array([{ name: 'Jane' }, { name: 'Joe' }])
    end
  end

  describe '#to_a' do
    it 'casts dataset to an array' do
      expect(dataset.to_a).to eql([{ name: 'Jane' }, { name: 'Joe' }])
    end
  end

  describe '#find_all' do
    it 'yields tuples through row_proc' do
      result = dataset.find_all { |tuple| tuple[:name] == 'Jane' }

      expect(result).to be_instance_of(klass)
      expect(result).to match_array([{ name: 'Jane' }])
    end
  end

  describe '#kind_of?' do
    it 'does not forward to data object' do
      expect(dataset).to be_kind_of(klass)
    end
  end

  describe '#instance_of?' do
    it 'does not forward to data object' do
      expect(dataset).to be_instance_of(klass)
    end
  end

  describe '#is_a?' do
    it 'does not forward to data object' do
      expect(dataset.is_a?(klass)).to be(true)
    end
  end
end
