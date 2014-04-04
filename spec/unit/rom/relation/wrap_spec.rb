# encoding: utf-8

require 'spec_helper'

describe Relation, '#wrap' do
  let(:users) { Relation.new(user_relation, user_mapper) }
  let(:tasks) { Relation.new(task_relation, task_mapper) }

  fake(:user_relation) { Axiom::Relation }
  fake(:user_mapper) { Mapper }

  fake(:task_relation) { Axiom::Relation }
  fake(:task_header) { Axiom::Relation::Header }
  fake(:task_mapper) { Mapper }

  fake(:wrapped_relation) { Axiom::Relation }
  fake(:wrapped_mapper) { Mapper }

  it "wraps relation and mapper" do
    stub(task_relation).header { task_header }
    stub(user_relation).wrap(:tasks => task_header) { wrapped_relation }
    stub(user_mapper).wrap(:tasks => task_mapper) { wrapped_mapper }

    expect(users.wrap(:tasks => tasks)).to eql(Relation.new(wrapped_relation, wrapped_mapper))

    expect(user_relation).to have_received.wrap(:tasks => task_header)
    expect(user_mapper).to have_received.wrap(:tasks => task_mapper)
  end
end
