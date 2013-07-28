require 'spec_helper'

describe Relation, '#update' do
  subject(:relation) { described_class.new(users, mapper) }

  include_context 'Relation'

  it 'updates old tuples with new ones' do
    user1.name = 'John Doe'
    expect(relation.update(user1).all.last).to eq(user1)
  end
end
