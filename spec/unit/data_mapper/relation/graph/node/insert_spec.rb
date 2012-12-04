require 'spec_helper'

describe Relation::Graph::Node, '#insert' do
  subject { object.insert user }

  let(:object)   { subclass.new(name, relation) }
  let(:name)     { :users }
  let(:relation) { mock('relation') }
  let(:user)     { mock('user') }

  it "delegates to relation" do
    relation.should_receive(:insert).with(user).and_return(user)
    subject.should be(user)
  end
end
