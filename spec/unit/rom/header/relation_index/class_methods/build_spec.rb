require 'spec_helper'

describe Header::RelationIndex, '.build' do
  subject { described_class.build(attribute_index) }

  let(:attribute_index) {
    Header::AttributeIndex.build(relation_name, attribute_names, strategy_class)
  }

  let(:relation_name)   { :users }
  let(:attribute_names) { [ :id ] }
  let(:strategy_class)  { Class.new }

  it { should eql(described_class.new({ :users => 1 })) }
end
