require 'rom/schema'

RSpec.describe ROM::Schema, '#finalize!' do
  context 'without inferrer' do
    subject(:schema) do
      define_schema(:users, id: :Integer, name: :String)
    end

    before { schema.finalize_attributes!.finalize! }

    it 'returns a frozen canonical schema' do
      expect(schema).to be_frozen
    end

    it 'gives access to the AST' do
      expect(schema.to_ast).to be_an Array
    end
  end

  context 'with inferrer' do
    subject(:schema) do
      ROM::Schema.define(
        :users,
        attributes: attributes,
        inferrer: ROM::Schema::DEFAULT_INFERRER.with(
          attributes_inferrer: attributes_inferrer,
          enabled: true
        )
      )
    end

    let(:attributes_inferrer) do
      proc { [ [define_attribute(:name, :String)], %i(id age) ] }
    end

    context 'when all required attributes are present' do
      let(:attributes) do
        [define_type(:id, :Integer), define_type(:age, :Integer)]
      end

      it 'concats defined attributes with inferred attributes' do
        expect(schema.finalize_attributes!.finalize!.map(&:name)).to eql(%i[id age name])
      end
    end

    context 'when inferred attributes are overridden' do
      let(:attributes) do
        [define_type(:id, :Integer),
         define_type(:age, :Integer),
         define_type(:name, :String).meta(custom: true)]
      end

      it 'respects overridden attributes' do
        expect(schema.finalize_attributes!.finalize!.map(&:name)).to eql(%i[id age name])
        expect(schema[:name].meta[:custom]).to be(true)
      end
    end

    context 'when some attributes are missing' do
      let(:attributes) do
        []
      end

      it 'raises error' do
        expect { schema.finalize_attributes!.finalize! }.
          to raise_error(
               ROM::Schema::Inferrer::MissingAttributesError,
               "Following attributes in :users schema cannot be inferred and "\
               "have to be defined explicitly: :id, :age"
             )
      end
    end
  end
end
