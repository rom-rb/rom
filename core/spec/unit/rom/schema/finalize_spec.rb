require 'rom/schema'

RSpec.describe ROM::Schema, '#finalize!' do
  context 'without inferrer' do
    subject(:schema) do
      define_schema(:users, id: :Int, name: :String)
    end

    before { schema.finalize! }

    it 'returns a frozen canonical schema' do
      expect(schema).to be_frozen
    end
  end

  context 'with inferrer' do
    subject(:schema) do
      ROM::Schema.define(:users, attributes: attributes, inferrer: inferrer)
    end

    let(:inferrer) do
      proc { [[define_type(:name, :String)], [:id, :age]]}
    end

    context 'when all required attributes are present' do
      let(:attributes) do
        [define_type(:id, :Int), define_type(:age, :Int)]
      end

      it 'concats defined attributes with inferred attributes' do
        expect(schema.finalize!.map(&:name)).to eql(%i[id age name])
      end
    end

    context 'when inferred attributes are overridden' do
      let(:attributes) do
        [define_type(:id, :Int),
         define_type(:age, :Int),
         define_type(:name, :String).meta(custom: true)]
      end

      it 'respects overridden attributes' do
        expect(schema.finalize!.map(&:name)).to eql(%i[id age name])
        expect(schema[:name].meta[:custom]).to be(true)
      end
    end

    context 'when some attributes are missing' do
      let(:attributes) do
        []
      end

      it 'raises error' do
        expect { schema.finalize! }.
          to raise_error(ROM::Schema::MissingAttributesError, /missing attributes in :users schema: :id, :age/)
      end
    end
  end
end
