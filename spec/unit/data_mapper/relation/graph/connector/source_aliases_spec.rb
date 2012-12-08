require 'spec_helper'

describe Relation::Graph::Connector, '#source_aliases' do
  subject { object.source_aliases }

  let(:object) { described_class.new(node, relationship, relations, DM_ENV) }

  let(:node)            { mock('relation_node', :name => mock, :aliases => aliases) }
  let(:aliases)         { {} }
  let(:relationship)    { mock('relationship', :name => mock) }
  let(:relations)       { mock('relations') }

  it { should be(aliases) }
end
