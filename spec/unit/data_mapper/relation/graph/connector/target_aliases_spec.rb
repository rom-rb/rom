require 'spec_helper'

describe Relation::Graph::Connector, '#target_aliases' do
  subject { object.target_aliases }

  let(:object) { described_class.new(node, relationship, relations, DM_ENV) }

  let(:node)            { mock('relation_node', :name => mock, :aliases => aliases) }
  let(:aliases)         { mock }
  let(:relationship)    { mock('relationship', :name => mock) }
  let(:relations)       { mock('relations') }

  it { should be(aliases) }
end
