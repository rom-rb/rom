require 'spec_helper'

describe Relation, '#sort_by' do
  subject(:relation) { described_class.new(users, mapper) }

  include_context 'Relation'

  it 'sorts relation by its attributes' do
    expect(relation.sort_by { |r| [ r.name ] }.all).to eq([ user2, user1 ])
  end
end
