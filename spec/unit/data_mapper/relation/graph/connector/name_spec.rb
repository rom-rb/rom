require 'spec_helper'

describe Relation::Graph::Connector, '#name' do
  subject { object.name }

  let(:object) { described_class.new(node, relationship, relations, DM_ENV) }

  let(:node)              { mock('relation_node', :name => node_name) }
  let(:node_name)         { :users_X_addresses }
  let(:relationship)      { mock('relationship', :name => relationship_name) }
  let(:relationship_name) { :addresses }
  let(:relations)         { mock('relations') }
  let(:connector_name)    { :"#{node_name}__#{relationship_name}" }

  it { should equal(connector_name) }
end
