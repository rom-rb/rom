require 'ostruct'
require 'rom/relation'

RSpec.describe ROM::Relation, '#map_with' do
  subject(:relation) do
    ROM::Relation.new(
      dataset,
      name: ROM::Relation::Name[:users],
      schema: ROM::Relation.default_schema,
      mappers: mappers
    )
  end

  let(:mappers) { ROM::MapperRegistry.new({}) }

  let(:dataset) do
    [{ id: 1, name: 'Jane' }, {id: 2, name: 'Joe' }]
  end

  context 'with custom mappers' do
    let(:mappers) do
      {
        name_list: -> users { users.map { |u| u[:name] } },
        upcase_names: -> names { names.map(&:upcase) },
        identity: -> users { users }
      }
    end

    it 'sends the relation through custom mappers' do
      expect(relation.map_with(:name_list, :upcase_names).to_a).to match_array(%w(JANE JOE))
    end

    it 'does not use the default mapper' do
      expect(relation.map_with(:identity).to_a).to eql(dataset)
    end

    it 'raises error when custom mapper is used with a model class' do
      expect { relation.map_with(:name_list, Class.new) }.
        to raise_error(ArgumentError, 'using custom mappers and a model is not supported')
    end
  end

  context 'setting custom model type' do
    it 'instantiates custom model' do
      expect(relation.with(auto_struct: true).map_with(OpenStruct).first).to be_instance_of(OpenStruct)
    end
  end
end
