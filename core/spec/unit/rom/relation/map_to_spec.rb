require 'ostruct'
require 'rom/relation'

RSpec.describe ROM::Relation, '#map_to' do
  subject(:relation) do
    ROM::Relation.new(
      dataset,
      name: ROM::Relation::Name[:users],
      schema: ROM::Relation.default_schema,
      mappers: mappers
    )
  end

  let(:mappers) { ROM::MapperRegistry.new }

  let(:dataset) do
    [{ id: 1, name: 'Jane' }, {id: 2, name: 'Joe' }]
  end

  it 'instantiates custom model' do
    expect(relation.with(auto_struct: true).map_to(OpenStruct).first).to be_instance_of(OpenStruct)
  end
end
