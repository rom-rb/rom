RSpec.describe ROM::Schema do
  describe '#to_h' do
    it 'returns hash with attributes' do
      attrs = { id: ROM::Types::Integer.meta(name: :id), name: ROM::Types::String.meta(name: :name) }
      schema = ROM::Schema.define(:name, attributes: attrs.values)

      expect(schema.to_h).to eql(attrs)
    end
  end

  describe '#to_ast' do
    specify do
      attrs = { id: ROM::Types::Integer.meta(name: :id), name: ROM::Types::String.meta(name: :name) }
      schema = ROM::Schema.define(:name, attributes: attrs.values)

      expect(schema.to_ast).
        to eql([:schema, [
                  :name,
                  [[:attribute, [:id, [:nominal, [Integer, {}]], {}]],
                   [:attribute, [:name, [:nominal, [String, {}]], {}]]]]])
    end
  end

  describe '#primary_key_names' do
    subject(:schema) { ROM::Schema.define(:name, attributes: attrs.values).finalize_attributes! }

    let(:attrs) do
      { user_id: ROM::Types::Integer.meta(name: :user_id, primary_key: true),
        group_id: ROM::Types::Integer.meta(name: :group_id, primary_key: true),
        name: ROM::Types::String.meta(name: :name) }
    end

    it 'returns the name of the primary key attribute' do
      expect(schema.primary_key_names).to eql(%i[user_id group_id])
    end

    it 'maintains primary key names' do
      expect(schema.project(:name).primary_key_names).to eql(%i[user_id group_id])
    end
  end

  describe '#primary_key_name' do
    subject(:schema) { ROM::Schema.define(:name, attributes: attrs.values).finalize_attributes! }

    let(:attrs) do
      { id: ROM::Types::Integer.meta(name: :id, primary_key: true), name: ROM::Types::String.meta(name: :name) }
    end

    it 'returns the name of the primary key attribute' do
      expect(schema.primary_key_name).to be(:id)
    end

    it 'maintains primary key name' do
      expect(schema.project(:name).primary_key_name).to be(:id)
    end
  end
end
