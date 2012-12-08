require 'spec_helper'

describe Relation::Graph::Node, '#update' do
  subject { object.update(key, tuple) }

  let(:object)   { subclass.new(:users, relation) }
  let(:relation) { mock('relation') }
  let(:user)     { mock('user') }
  let(:key)      { 1 }
  let(:tuple)    { {} }

  it "delegates to relation" do
    relation.should_receive(:update).with(key, tuple).and_return(user)
    subject.should be(user)
  end
end
