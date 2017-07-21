RSpec.describe ROM::Attribute do
  describe '#to_ast' do
    subject(:attribute) { ROM::Attribute.new(ROM::Types::Int).meta(name: :id) }

    types = [
      ROM::Types::Int,
      ROM::Types::Strict::Int,
      ROM::Types::Strict::Int.optional
    ]

    to_attr = -> type { ROM::Attribute.new(type).meta(name: :id) }

    types.each do |type|
      specify do
        expect(to_attr.(type).to_ast).to eql([:attribute, [:id, type.to_ast, {}]])
      end
    end

    example 'wrapped type' do
      expect(attribute.wrapped(:users).to_ast).
        to eql([:attribute, [:id,
                             ROM::Types::Int.to_ast,
                             wrapped: true, alias: :users_id]])
    end
  end

  describe '#optional' do
    subject(:attribute) { ROM::Attribute.new(ROM::Types::Int).meta(read: ROM::Types::Coercible::Int) }

    it 'transforms read type' do
      expect(attribute.optional.to_read_type['1']).to eql(1)
      expect(attribute.optional.to_read_type[nil]).to be_nil
    end
  end
end
