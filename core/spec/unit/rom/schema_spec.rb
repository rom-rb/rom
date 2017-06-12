RSpec.describe ROM::Schema do
  describe '#to_h' do
    it 'returns hash with attributes' do
      attrs = { id: ROM::Types::Int.meta(name: :id), name: ROM::Types::String.meta(name: :name) }
      schema = ROM::Schema.define(:name, attributes: attrs.values)

      expect(schema.to_h).to eql(attrs)
    end
  end

  describe '#to_ast' do
    specify do
      attrs = { id: ROM::Types::Int.meta(name: :id), name: ROM::Types::String.meta(name: :name) }
      schema = ROM::Schema.define(:name, attributes: attrs.values)

      expect(schema.to_ast).
        to eql([:schema, [
                  :name,
                  [[:attribute, [:id, [:definition, [Integer, name: :id]]]],
                   [:attribute, [:name, [:definition, [String, name: :name]]]]]]])
    end
  end
end
