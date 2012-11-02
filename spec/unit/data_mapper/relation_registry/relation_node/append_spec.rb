require 'spec_helper'

describe RelationRegistry::RelationNode, '#<<' do
  subject { object << user }

  let(:object)   { described_class.new(name, relation) }
  let(:name)     { :users }
  let(:relation) { mock('relation') }
  let(:user)     { mock('user') }

  it "delegates to relation" do
    relation.should_receive(:<<).with(user)
    subject.should be(subject)
  end
end
