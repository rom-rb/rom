require 'spec_helper'

describe Relation::Aliases::AttributeIndex, '.build' do
  subject { described_class.build(relation_name, attribute_set, strategy_class) }

  let(:relation_name)       { :users }
  let(:attribute_set)       { AttributeSet.new << primitive_attribute << custom_attribute }
  let(:primitive_attribute) { mock_attribute(:id,   Integer) }
  let(:custom_attribute)    { mock_attribute(:name, mock)  }
  let(:strategy_class)      { mock }
  let(:initial_entries)     { { attribute_alias(:id, :users) => attribute_alias(:id, :users) } }

  it { should eql(described_class.new(initial_entries, strategy_class)) }
end
