require 'spec_helper'

describe Relation::Aliases::RelationIndex, '.build' do
  subject { described_class.build(attribute_index) }

  let(:attribute_index) {
    Relation::Aliases::AttributeIndex.build(relation_name, attribute_set, strategy_class)
  }

  let(:relation_name)  { :users }
  let(:attribute_set)  { AttributeSet.new << mock_attribute(:id, Integer) }
  let(:strategy_class) { mock }

  it { should eql(described_class.new({ :users => 1 })) }
end
