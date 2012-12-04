require 'spec_helper'

# TODO make these specs more strict!
describe Engine::Veritas::Node, '#join' do
  subject { object.join(other) }

  let(:object)          { described_class.new(:users,   source_relation, source_aliases) }
  let(:other)           { described_class.new(:address, target_relation, target_aliases) }
  let(:source_relation) { mock('source_relation') }
  let(:target_relation) { mock('target_relation') }
  let(:join_relation)   { mock('join_relation') }

  let(:source_aliases) { Relation::Graph::Node::Aliases::Unary.new({ :users_id     => :users_id     }, { :id => :users_id }) }
  let(:target_aliases) { Relation::Graph::Node::Aliases::Unary.new({ :addresses_id => :addresses_id }, { :id => :addresses_id }) }
  let(:joined_aliases) { source_aliases.join(target_aliases, {}) }

  before do
    source_relation.should_receive(:rename).with(joined_aliases).and_return(source_relation)
    source_relation.should_receive(:join).with(target_relation).and_return(join_relation)
  end

  it { should be_instance_of(described_class) }

  its(:relation) { should be(join_relation) }
end
