require 'spec_helper'

describe Relation::Graph::Node, '#join' do
  subject { object.join(other, join_definition) }

  let(:object)           { described_class.new(:users,     source_relation, source_header) }
  let(:other)            { described_class.new(:addresses, target_relation, target_header) }
  let(:join_definition)  { { :id => :id } }

  let(:source_relation)  { mock_relation('users',     [ [ :id, Integer ] ]) }
  let(:target_relation)  { mock_relation('addresses', [ [ :id, Integer ] ]) }

  let(:source_header)    { Relation::Header.new(source_a_index, source_r_index) }
  let(:target_header)    { Relation::Header.new(target_a_index, target_r_index) }
  let(:source_a_index)   { Relation::Header::AttributeIndex.new(source_a_entries, strategy) }
  let(:source_a_entries) { { attribute_alias(:id, :users) => attribute_alias(:id, :users) } }
  let(:target_a_index)   { Relation::Header::AttributeIndex.new(target_a_entries, strategy) }
  let(:target_a_entries) { { attribute_alias(:id, :addresses) => attribute_alias(:id, :addresses) } }
  let(:source_r_index)   { Relation::Header::RelationIndex.new(:users     => 1) }
  let(:target_r_index)   { Relation::Header::RelationIndex.new(:addresses => 1) }
  let(:strategy)         { described_class.send(:join_strategy) }

  let(:joined_header)    { source_header.join(target_header, join_definition) }
  let(:join_relation)    { source_relation.join(target_relation.rename(joined_header.aliases)) }

  it { should be_instance_of(described_class) }

  its(:relation) { should eql(join_relation) }
  its(:header)   { should eql(joined_header) }
end
