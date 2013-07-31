# encoding: utf-8

require 'spec_helper'

describe Relation, '#insert' do
  include_context 'Relation'

  let(:user) { model.new(name: 'Piotr') }

  it 'inserts object into relation' do
    expect(relation.insert(user).to_a).to include(user)
  end
end
