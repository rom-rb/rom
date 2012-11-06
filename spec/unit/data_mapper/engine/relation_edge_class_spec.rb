require 'spec_helper'

describe Engine, '#relation_edge_class' do
  subject { object.relation_edge_class }

  let(:object) { subclass.new }

  it { should be(RelationRegistry::RelationEdge) }
end
