require 'spec_helper'

describe Relation::Header::RelationIndex, '.build' do
  subject { described_class.build(attribute_index) }

  let(:attribute_index) {
    Relation::Header::AttributeIndex.build(relation_name, attribute_names, strategy_class)
  }

  let(:relation_name)   { :users }
  let(:attribute_names) { [ :id ] }
  let(:strategy_class)  { mock }

  it { should eql(described_class.new({ :users => 1 })) }
end
