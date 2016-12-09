RSpec.describe ROM::Schema do
  describe '#to_h' do
    it 'returns hash with attributes' do
      attrs = { id: ROM::Types::Int, name: ROM::Types::String }
      schema = ROM::Schema.new(:name, attributes: attrs)

      expect(schema.to_h).to eql(attrs)
    end
  end
end
