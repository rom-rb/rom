require 'rom/types'
require 'rom/attribute'

RSpec.describe ROM::Attribute, '#method_missing' do
  subject(:attribute) do
    ROM::Attribute.new(type, name: :foo)
  end

  context 'with a plain definition' do
    let(:type) do
      ROM::Types::Integer
    end

    it 'forwards to its type' do
      expect(attribute.primitive).to be(Integer)
    end

    it 'raises when unknown method was called' do
      expect { attribute.not_here }.to raise_error(NoMethodError, /not_here/)
    end
  end

  context 'with a type that can return new instances of its class' do
    let(:type) do
      ROM::Types::Integer.default(1)
    end

    it 'returns a new attribute if forwarded method returned a new type' do
      new_attribute = attribute.default(2)

      expect(new_attribute[]).to be(2)
    end
  end
end
