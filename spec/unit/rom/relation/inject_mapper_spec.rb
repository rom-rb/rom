require 'spec_helper'

describe Relation, '#inject_mapper' do
  subject(:relation) { described_class.new([], mapper) }

  fake(:mapper)
  fake(:other_mapper) { Mapper }

  it 'returns new relation with injected new mapper' do
    other_relation = relation.inject_mapper(other_mapper)

    expect(other_relation.relation).to be(relation.relation)
    expect(other_relation.mapper).to be(other_mapper)
  end
end
