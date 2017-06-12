RSpec.describe ROM::Schema::Attribute do
  describe '#to_ast' do

    types = [
      ROM::Types::Int,
      ROM::Types::Strict::Int,
      ROM::Types::Strict::Int.optional
    ]

    attribute = -> type { ROM::Schema::Attribute.new(type).meta(name: :id) }

    types.each do |type|
      specify do
        expect(attribute.(type).to_ast).to eql([:attribute, [:id, type.meta(name: :id).to_ast]])
      end
    end
  end
end
