# encoding: utf-8

require 'spec_helper'

describe Relation, '#first' do
  include_context 'Relation'

  it 'returns first n-tuples' do
    expect(relation.first.to_a).to include(model.new(name: 'Jane'))
    expect(relation.first.count).to be(1)
  end
end
