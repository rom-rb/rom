require 'ostruct'
require 'rom/relation'

RSpec.describe ROM::Relation, '#map_to' do
  subject(:relation) do
    ROM::Relation.new(
      dataset,
      name: ROM::Relation::Name[:users],
      schema: ROM::Relation.default_schema,
      mappers: mapper_registry
    )
  end

  let(:mapper_registry) { ROM::MapperRegistry.build(mappers) }

  let(:dataset) do
    [{ id: 1, name: 'Jane' }, { id: 2, name: 'Joe' }]
  end

  context 'without custom mappers' do
    let(:mappers) { {} }

    it 'instantiates custom model when auto_struct is enabled' do
      expect(relation.with(auto_struct: true).map_to(OpenStruct).first).to be_instance_of(OpenStruct)
    end

    it 'instantiates custom model when auto_struct is disabled' do
      expect(relation.map_to(OpenStruct).first).to be_instance_of(OpenStruct)
    end
  end

  context 'with custom mappers' do
    let(:mappers) do
      { name_list: -> users { users.map { |u| { name: u[:name] } } } }
    end

    it 'instantiates custom model when auto_struct is disabled' do
      user = relation.with(auto_struct: false).map_with(:name_list).map_to(OpenStruct).first

      expect(user).to be_instance_of(OpenStruct)
      expect(user.id).to be(nil)
      expect(user.name).to eql('Jane')
    end
  end
end
