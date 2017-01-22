RSpec.describe ROM::Changeset do
  let(:jane) { { id: 2, name: "Jane" } }
  let(:relation) { double(ROM::Relation, primary_key: :id, name: :users) }

  describe '.[]' do
    it 'returns a changeset preconfigured for a specific relation' do
      klass = ROM::Changeset::Create[:users]

      expect(klass.relation).to be(:users)
      expect(klass < ROM::Changeset::Create).to be(true)
    end

    it 'caches results' do
      create = ROM::Changeset::Create[:users]
      update = ROM::Changeset::Update[:users]

      expect(create).to be(ROM::Changeset::Create[:users])
      expect(create < ROM::Changeset::Create).to be(true)

      expect(update).to be(ROM::Changeset::Update[:users])
      expect(update < ROM::Changeset::Update).to be(true)
    end
  end

  describe '#diff' do
    it 'returns a hash with changes' do
      expect(relation).to receive(:fetch).with(2).and_return(jane)

      changeset = ROM::Changeset::Update.new(relation, __data__: { name: "Jane Doe" }, primary_key: 2)

      expect(changeset.diff).to eql(name: "Jane Doe")
    end
  end

  describe '#diff?' do
    it 'returns true when data differs from the original tuple' do
      expect(relation).to receive(:fetch).with(2).and_return(jane)

      changeset = ROM::Changeset::Update.new(relation, __data__: { name: "Jane Doe" }, primary_key: 2)

      expect(changeset).to be_diff
    end

    it 'returns false when data are equal to the original tuple' do
      expect(relation).to receive(:fetch).with(2).and_return(jane)

      changeset = ROM::Changeset::Update.new(relation, __data__: { name: "Jane" }, primary_key: 2)

      expect(changeset).to_not be_diff
    end
  end

  describe '#clean?' do
    it 'returns true when data are equal to the original tuple' do
      expect(relation).to receive(:fetch).with(2).and_return(jane)

      changeset = ROM::Changeset::Update.new(relation, __data__: { name: "Jane" }, primary_key: 2)

      expect(changeset).to be_clean
    end

    it 'returns false when data differs from the original tuple' do
      expect(relation).to receive(:fetch).with(2).and_return(jane)

      changeset = ROM::Changeset::Update.new(relation, __data__: { name: "Jane Doe" }, primary_key: 2)

      expect(changeset).to_not be_clean
    end
  end

  describe 'quacks like a hash' do
    subject(:changeset) { ROM::Changeset::Create.new(relation, __data__: data) }

    let(:data) { instance_double(Hash, class: Hash) }

    it 'delegates to its data hash' do
      expect(data).to receive(:[]).with(:name).and_return('Jane')

      expect(changeset[:name]).to eql('Jane')
    end

    it 'maintains its own type' do
      expect(data).to receive(:merge).with(foo: 'bar').and_return(foo: 'bar')

      new_changeset = changeset.merge(foo: 'bar')

      expect(new_changeset).to be_instance_of(ROM::Changeset::Create)
      expect(new_changeset.options).to eql(changeset.options.merge(__data__: { foo: 'bar' }))
      expect(new_changeset.to_h).to eql(foo: 'bar')
    end

    it 'raises NoMethodError when an unknown message was sent' do
      expect { changeset.not_here }.to raise_error(NoMethodError, /not_here/)
    end
  end

  describe 'quacks like an array' do
    subject(:changeset) { ROM::Changeset::Create.new(relation, __data__: data) }

    let(:data) { instance_double(Array, class: Array) }

    it 'delegates to its data hash' do
      expect(data).to receive(:[]).with(1).and_return('Jane')

      expect(changeset[1]).to eql('Jane')
    end

    it 'maintains its own type' do
      expect(data).to receive(:+).with([1, 2]).and_return([1, 2])

      new_changeset = changeset + [1, 2]

      expect(new_changeset).to be_instance_of(ROM::Changeset::Create)
      expect(new_changeset.options).to eql(changeset.options.merge(__data__: [1, 2]))
      expect(new_changeset.to_a).to eql([1, 2])
    end

    it 'raises NoMethodError when an unknown message was sent' do
      expect { changeset.not_here }.to raise_error(NoMethodError, /not_here/)
    end
  end

  describe '#inspect' do
    subject(:changeset) { ROM::Changeset::Create.new(relation).data(name: 'Jane') }

    specify do
      expect(changeset.inspect).
        to eql('#<ROM::Changeset::Create relation=:users data={:name=>"Jane"}>')
    end
  end
end
