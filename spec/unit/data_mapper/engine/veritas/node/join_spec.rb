require 'spec_helper'

# TODO make these specs more strict!
describe Engine::Veritas::Node, '#join' do
  subject { object.join(other, join_definition) }

  let(:object)          { described_class.new(:users,   source_relation, source_aliases) }
  let(:other)           { described_class.new(:address, target_relation, target_aliases) }
  let(:source_relation) { mock('source_relation') }
  let(:target_relation) { mock('target_relation') }
  let(:join_relation)   { mock('join_relation') }

  let(:source_aliases)  { Relation::Aliases.new(source_index, source_r_index) }
  let(:target_aliases)  { Relation::Aliases.new(target_index, target_r_index) }
  let(:source_index)    { Relation::Aliases::AttributeIndex.new({ attribute_alias(:id, :users)     => attribute_alias(:id, :users) }, strategy) }
  let(:target_index)    { Relation::Aliases::AttributeIndex.new({ attribute_alias(:id, :addresses) => attribute_alias(:id, :addresses) }, strategy) }
  let(:source_r_index)  { Relation::Aliases::RelationIndex.new(:users     => 1) }
  let(:target_r_index)  { Relation::Aliases::RelationIndex.new(:addresses => 1) }
  let(:strategy)        { Relation::Graph::Node.send(:aliasing_strategy) }
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
