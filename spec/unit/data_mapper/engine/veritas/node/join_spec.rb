require 'spec_helper'

# TODO make these specs more strict!
describe Engine::Veritas::Node, '#join' do
  subject { object.join(other, join_definition) }

  let(:object)          { described_class.new(:users,   source_relation, source_aliases) }
  let(:other)           { described_class.new(:address, target_relation, target_aliases) }
  let(:source_relation) { mock_relation('source_relation', [ :id ]) }
  let(:target_relation) { mock_relation('target_relation', [ :id ]) }
  let(:join_relation)   { source_relation.join(target_relation.rename(joined_aliases)) }

  let(:source_aliases)  { Relation::Aliases.new(source_a_index, source_r_index) }
  let(:target_aliases)  { Relation::Aliases.new(target_a_index, target_r_index) }
  let(:source_a_index)  { Relation::Aliases::AttributeIndex.new({ attribute_alias(:id, :users)     => attribute_alias(:id, :users)     }, strategy) }
  let(:target_a_index)  { Relation::Aliases::AttributeIndex.new({ attribute_alias(:id, :addresses) => attribute_alias(:id, :addresses) }, strategy) }
  let(:source_r_index)  { Relation::Aliases::RelationIndex.new(:users     => 1) }
  let(:target_r_index)  { Relation::Aliases::RelationIndex.new(:addresses => 1) }
  let(:strategy)        { described_class.send(:aliasing_strategy) }
  let(:joined_aliases)  { source_aliases.join(target_aliases, join_definition) }
  let(:join_definition) { { :id => :id } }

  it { should be_instance_of(described_class) }

  its(:relation) { should eql(join_relation) }
  its(:aliases)  { should eql(joined_aliases) }
end
