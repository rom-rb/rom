require 'spec_helper'

describe Header do
  describe '.coerce' do
    subject(:header) { Header.coerce([[:name, type: String]]) }

    it 'returns a header with coerced attributes' do
      expected = Header.new(name: Header::Attribute.coerce([:name, type: String]))

      expect(header).to eql(expected)
      expect(header.name.type).to be(String)
    end
  end
end
