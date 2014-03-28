require "spec_helper"

describe Mapper::Attribute::EmbeddedValue, '#to_ast' do
  subject(:attribute) { Mapper::Attribute::EmbeddedValue.build(:model, node: mapper.loader.node) }

  let(:mapper) { Mapper.build([[:id]], model: model) }
  let(:model) { mock_model(:id) }

  it 'returns a morpher transformer node' do
    loader = Morpher.compile(attribute.to_ast)
    object = model.new(id: 1)
    tuple  = { model: { id: 1 } }

    expect(loader.call(tuple)).to eql([:model, object])
  end
end
