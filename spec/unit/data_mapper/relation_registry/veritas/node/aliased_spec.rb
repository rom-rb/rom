require 'spec_helper'

describe RelationRegistry::Veritas::Node, '#aliased' do
  subject { object.aliased }

  let(:object)           { described_class.new(:users, relation, aliases) }
  let(:relation)         { mock('relation') }
  let(:aliased_relation) { mock('aliased_relation') }
  let(:aliases)          { { :id => :user_id } }

  before do
    relation.should_receive(:rename).with(aliases).and_return(aliased_relation)
  end

  it { should be_instance_of(described_class) }

  its(:relation) { should be(aliased_relation) }
end
