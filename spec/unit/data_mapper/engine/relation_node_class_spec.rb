require 'spec_helper'

describe Engine, '#relation_node_class' do
  subject { object.relation_node_class }

  let(:object) { subclass.new }

  it { should be(RelationRegistry::RelationNode) }
end
