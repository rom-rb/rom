# encoding: utf-8

require 'spec_helper'

describe Relation, '#sort_by' do
  include_context 'Relation'

  it 'sorts relation by its attributes' do
    expect(relation.sort_by { |r| [r.name] }.all).to eq([user2, user1])
  end
end
