# encoding: utf-8

require 'spec_helper'

describe Relation, '#group' do
  let(:users) { Relation.new(user_relation, user_mapper) }
  let(:tasks) { Relation.new(task_relation, task_mapper) }

  fake(:user_relation) { Axiom::Relation }
  fake(:user_mapper) { Mapper }

  fake(:task_relation) { Axiom::Relation }
  fake(:task_header) { Axiom::Relation::Header }
  fake(:task_mapper) { Mapper }

  fake(:groupped_relation) { Axiom::Relation }
  fake(:groupped_mapper) { Mapper }

  it "groups relation and mapper" do
    stub(task_relation).header { task_header }
    stub(user_relation).group(:tasks => task_header) { groupped_relation }
    stub(user_mapper).group(:tasks => task_mapper) { groupped_mapper }

    expect(users.group(:tasks => tasks)).to eql(Relation.new(groupped_relation, groupped_mapper))

    expect(user_relation).to have_received.group(:tasks => task_header)
    expect(user_mapper).to have_received.group(:tasks => task_mapper)
  end
end
