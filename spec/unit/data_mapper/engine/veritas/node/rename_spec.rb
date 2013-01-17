require 'spec_helper'

describe Engine::Veritas::Node, '#rename' do
  subject { object.rename(aliases) }

  let(:aliases)          { { :id => :foo_id } }

  let(:object)           { described_class.new(name, relation, header) }
  let(:name)             { :users }
  let(:relation)         { mock_relation(:users, [[:id, Integer]]) }
  let(:header)           { Relation::Header.new(attribute_index, relation_index) }
  let(:attribute_index)  { Relation::Header::AttributeIndex.new(initial_entries, strategy) }
  let(:initial_entries)  { { attribute_alias(:id, :users) => attribute_alias(:id, :users) } }
  let(:relation_index)   { Relation::Header::RelationIndex.new(:users => 1) }
  let(:strategy)         { described_class.send(:join_strategy) }

  let(:renamed_header)   { header.rename(aliases) }
  let(:renamed_relation) { relation.rename(renamed_header.aliases) }

  it { should be_instance_of(described_class) }

  its(:relation) { should eql(renamed_relation) }
  its(:header)   { should eql(renamed_header)   }
end
