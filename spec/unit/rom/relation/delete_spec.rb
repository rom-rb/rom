require 'spec_helper'

describe Relation, '#delete' do
  subject(:relation) { described_class.new(users, mapper) }

  include_context 'Relation'

  it 'deletes tuples from the relation' do
    expect(relation.delete(user).all).not_to include(user)
  end
end
