# encoding: utf-8

require 'spec_helper'

describe Relation, '#inject_reader' do
  subject(:relation) { described_class.new([], mapper) }

  fake(:mapper)
  fake(:other_reader) { Relation::Reader }

  it 'returns new relation with injected new mapper' do
    other_relation = relation.inject_reader(other_reader)

    expect(other_relation.relation).to be(relation.relation)
    expect(other_relation.mapper).to be(relation.mapper)
    expect(other_relation.reader).to be(other_reader)
  end
end
