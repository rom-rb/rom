# encoding: utf-8

require 'spec_helper'

describe Relation, '#update' do
  include_context 'Relation'

  it 'updates old tuples with new ones' do
    john.name = 'John Doe'
    expect(relation.update(john).to_a.last).to eq(john)
  end
end
