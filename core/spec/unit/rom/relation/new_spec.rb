require 'rom/relation'

RSpec.describe ROM::Relation, '#new' do
  subject(:relation) do
    Class.new(ROM::Relation) do
      schema(:users) do
        attribute :id, ROM::Types::String, read: ROM::Types::Coercible::Integer
        attribute :name, ROM::Types::String
      end
    end.new([], **options)
  end

  let(:options) { {} }

  it 'returns a new relation with a new dataset' do
    ds = []

    expect(relation.new(ds).dataset).to be(ds)
  end

  it 'returns a new relation with a new dataset and new options' do
    ds = []
    new_rel = relation.new(ds, name: :new_name)

    expect(new_rel.dataset).to be(ds)
    expect(new_rel.name).to be(:new_name)
  end

  it 'returns a new relation with a re-stablished input/output schemas' do
    ds = []
    new_rel = relation.new(ds, schema: relation.schema.project(:id))

    expect(new_rel.dataset).to be(ds)

    expect(new_rel.input_schema).not_to be(relation.input_schema)
    expect(new_rel.output_schema).not_to be(relation.output_schema)
  end
end
