require "spec_helper"

describe Mapper::Attribute, '#rename' do
  subject(:attribute) { Mapper::Attribute.build(:title) }

  it 'returns a new attribute with changed name' do
    expect(attribute.rename(:book_title)).to eql(Mapper::Attribute.build(:book_title))
  end
end
