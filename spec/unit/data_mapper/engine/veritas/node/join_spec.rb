require 'spec_helper'

describe Engine::Veritas::Node, '#join' do
  subject { object.join(other) }

  let(:object)          { described_class.new(:users,   source_relation, aliases) }
  let(:other)           { described_class.new(:address, target_relation) }
  let(:source_relation) { mock('source_relation') }
  let(:target_relation) { mock('target_relation') }
  let(:join_relation)   { mock('join_relation') }

  let(:aliases) { { :id => :user_id } }

  before do
    source_relation.should_receive(:rename).with(aliases).and_return(source_relation)
    source_relation.should_receive(:join).with(target_relation).and_return(join_relation)
    other.should_receive(:aliased).and_return(other)
  end

  it { should be_instance_of(described_class) }

  its(:relation) { should be(join_relation) }
end
