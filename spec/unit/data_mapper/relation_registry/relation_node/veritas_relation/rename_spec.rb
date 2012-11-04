require 'spec_helper'

describe RelationRegistry::RelationNode::VeritasRelation, '#rename' do
  subject { object.rename(new_aliases) }

  let(:object)   { described_class.new(:users, relation, aliases) }
  let(:relation) { mock('relation') }

  let(:aliases)     { { :id => :user_id } }
  let(:new_aliases) { { :name => :user_name} }

  it { should be_instance_of(described_class) }

  its(:aliases) { should eql(aliases.merge(new_aliases)) }
end
