require "spec_helper"

describe Mapper::Attribute, '#to_ast' do
  subject(:attribute) { Mapper::Attribute.build(:title) }

  it 'returns a morpher transformer node' do
    expect(Morpher.compile(attribute.to_ast).call(title: 'Title')).to eql([:title, 'Title'])
  end
end
