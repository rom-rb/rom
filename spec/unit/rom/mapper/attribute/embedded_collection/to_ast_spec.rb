require "spec_helper"

describe Mapper::Attribute::EmbeddedCollection, '#to_ast' do
  subject(:attribute) { Mapper::Attribute::EmbeddedCollection.build(:tasks, node: mapper.loader.node) }

  let(:mapper) { Mapper.build([[:id]], model: model) }
  let(:model) { mock_model(:id) }

  it 'returns a morpher transformer node' do
    loader = Morpher.compile(attribute.to_ast)

    task1 = model.new(id: 1)
    task2 = model.new(id: 1)
    tuple = { tasks: [{ id: 1 }, { id: 1 }] }

    expect(loader.call(tuple)).to eql([:tasks, [task1, task2]])
  end
end
