RSpec.describe ROM::Schema do
  describe '#to_h' do
    it 'returns hash with attributes' do
      attrs = {
        id: define_attr_info(:Integer, name: :id),
        name: define_attr_info(:String, name: :name)
      }
      schema = ROM::Schema.define(:name, attributes: attrs.values)

      expect(schema.to_h).to eql(id: ROM::Attribute.new(ROM::Types::Integer, name: :id),
                                 name: ROM::Attribute.new(ROM::Types::String, name: :name))
    end
  end

  describe '#to_ast' do
    specify do
      attrs = {
        id: define_attr_info(:Integer, name: :id),
        name: define_attr_info(:String, name: :name)
      }
      schema = ROM::Schema.define(:name, attributes: attrs.values)

      expect(schema.to_ast).
        to eql([:schema, [
                  :name,
                  [[:attribute, [:id, [:nominal, [Integer, {}]], alias: nil]],
                   [:attribute, [:name, [:nominal, [String, {}]], alias: nil]]]
                ]])
    end
  end

  describe '#primary_key_names' do
    subject(:schema) { ROM::Schema.define(:name, attributes: attrs.values).finalize_attributes! }

    let(:attrs) do
      {
        user_id: define_attr_info(:Integer, { name: :user_id }, primary_key: true),
        group_id: define_attr_info(:Integer, { name: :group_id }, primary_key: true),
        name_id: define_attr_info(:String, name: :name)
      }
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
      {
        id: define_attr_info(:Integer, { name: :id }, primary_key: true),
        name: define_attr_info(:String, name: :name)
      }
    end

    it 'returns the name of the primary key attribute' do
      expect(schema.primary_key_name).to be(:id)
    end

    it 'maintains primary key name' do
      expect(schema.project(:name).primary_key_name).to be(:id)
    end
  end

  describe '#alias_mapping' do
    it 'returns a hash from canonical name to alias including aliased attributes' do
      attrs = { id: ROM::Types::Integer.meta(name: :id, alias: :pk), name: ROM::Types::String }
      schema = ROM::Schema.define(:name, attributes: attrs.values)

      expect(schema.alias_mapping).to eq(id: :pk)
    end
  end
end
