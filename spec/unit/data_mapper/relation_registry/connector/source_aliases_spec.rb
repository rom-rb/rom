require 'spec_helper'

describe RelationRegistry::Connector, '#source_aliases' do
  subject { object.source_aliases }

  let(:object) { described_class.new(node, relationship, relations) }

  let(:node)            { mock('relation_node', :name => name, :aliases => aliases) }
  let(:name)            { :users_X_addresses }
  let(:aliases)         { {} }
  let(:relationship)    { mock('relationship') }
  let(:relations)       { mock('relations') }

  it { should be(aliases) }
end
