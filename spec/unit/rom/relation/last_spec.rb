# encoding: utf-8

require 'spec_helper'

describe Relation, '#last' do
  include_context 'Relation'

  it 'returns last n-tuples' do
    expect(relation.last.to_a).to include(model.new(name: 'John'))
    expect(relation.last.count).to be(1)
  end
end
