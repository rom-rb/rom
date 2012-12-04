require 'spec_helper'

describe Relation::Graph::Connector, '#source_model' do
  subject { object.source_model }

  let(:object) { described_class.new(node, relationship, relations) }

  let(:node)         { mock('relation_node', :name => mock) }
  let(:relationship) { mock('relationship', :name => mock, :source_model => source_model, :target_model => target_model) }
  let(:source_model) { mock('User') }
  let(:target_model) { mock('Address') }
  let(:relations)    { mock('relations') }

  it { should be(source_model) }
end
