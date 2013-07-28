require 'spec_helper'

describe Relation, '#delete' do
  subject(:relation) { described_class.new(users, mapper) }

  include_context 'Relation'

  it 'deletes tuples from the relation' do
    expect(relation.delete(user1).all).not_to include(user1)
  end
end
