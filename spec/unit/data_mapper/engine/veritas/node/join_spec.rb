require 'spec_helper'

# TODO make these specs more strict!
describe Engine::Veritas::Node, '#join' do
  subject { object.join(other, join_definition) }

  let(:object)          { described_class.new(:users,   source_relation, source_aliases) }
  let(:other)           { described_class.new(:address, target_relation, target_aliases) }
  let(:source_relation) { mock('source_relation') }
  let(:target_relation) { mock('target_relation') }
  let(:join_relation)   { mock('join_relation') }

  let(:source_aliases)  { Relation::Graph::Node::Aliases.new({ :users_id     => :id }) }
  let(:target_aliases)  { Relation::Graph::Node::Aliases.new({ :addresses_id => :id }) }
  let(:joined_aliases)  { mock('joined_aliases') }
  let(:join_definition) { {} }

  before do
    source_aliases.should_receive(:join).with(target_aliases, join_definition).and_return(joined_aliases)
    source_relation.should_receive(:rename).with(joined_aliases).and_return(source_relation)
    source_relation.should_receive(:join).with(target_relation).and_return(join_relation)
  end

  it { should be_instance_of(described_class) }

  its(:relation) { should be(join_relation) }
  its(:aliases)  { should be(joined_aliases) }
end
