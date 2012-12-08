require 'spec_helper'

describe Relation::Graph::Node, '#delete' do
  subject { object.delete(key) }

  let(:object)   { subclass.new(:users, relation) }
  let(:relation) { mock('relation') }
  let(:user)     { mock('user') }
  let(:key)      { 1 }

  it "delegates to relation" do
    relation.should_receive(:delete).with(key).and_return(user)
    subject.should be(user)
  end
end
