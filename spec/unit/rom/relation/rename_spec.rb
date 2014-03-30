# encoding: utf-8

require 'spec_helper'

describe Relation, '#rename' do
  subject(:relation) { users.rename(:user_name => :name) }

  let(:users) do
    Relation.new(
      Axiom::Relation.new([[:user_name, String]], [['Jane']]),
      Mapper.build([[:user_name]], model: model)
    )
  end

  let(:model) { mock_model(:name) }
  let(:user) { model.new(name: 'Jane') }

  it "renames the attributes" do
    expect(relation.to_a.first).to eql(user)
  end
end
