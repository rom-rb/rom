require 'spec_helper'

describe Relation::Header::AttributeIndex, '.build' do
  subject { described_class.build(relation_name, attribute_names, strategy_class) }

  let(:relation_name)   { :users }
  let(:attribute_names) { [ :id ] }
  let(:strategy_class)  { mock }
  let(:initial_entries) { { attribute_alias(:id, :users) => attribute_alias(:id, :users) } }

  it { should eql(described_class.new(initial_entries, strategy_class)) }
end
