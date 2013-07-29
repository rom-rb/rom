# encoding: utf-8

require 'spec_helper'

describe Relation, '#delete' do
  include_context 'Relation'

  it 'deletes tuples from the relation' do
    expect(relation.delete(user1).all).not_to include(user1)
  end
end
