require  'rom/memory'

RSpec.describe ROM::Relation, '#output_schema' do
  subject(:relation) do
    Class.new(ROM::Relation[:memory]) do
      schema do
        attribute :id, ROM::Types::String, read: ROM::Types::Int
        attribute :name, ROM::Types::String
      end
    end.new(ROM::Memory::Dataset.new([]))
  end

  let(:schema) do
    relation.schema
  end

  it 'returns output_schema based on canonical schema' do
    expect(relation.output_schema).
      to eql(ROM::Schema::HASH_SCHEMA.schema(id: schema[:id].to_read_type, name: schema[:name].type))
  end

  it 'returns output_schema based on projected schema' do
    projected = relation.project(schema[:id].aliased(:user_id))

    expect(projected.output_schema).
      to eql(ROM::Schema::HASH_SCHEMA.schema(user_id: projected.schema[:id].to_read_type))
  end
end
