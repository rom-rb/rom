require 'spec_helper'

describe Relation::Aliases::AttributeIndex, '#join' do
  subject { object.join(other, join_definition) }

  let(:object) { described_class.new(entries, strategy_class) }
  let(:other)  { described_class.new(other_entries, strategy_class) }

  let(:entries)         { { initial       => current } }
  let(:other_entries)   { { other_initial => other_current } }
  let(:initial)         { attribute_alias(:initial_id, :users) }
  let(:current)         { attribute_alias(:current_id, :users) }
  let(:other_initial)   { attribute_alias(:initial_id, :addresses) }
  let(:other_current)   { attribute_alias(:current_id, :addresses) }
  let(:strategy_class)  { mock }
  let(:strategy)        { mock }
  let(:joined_index)    { mock }
  let(:join_definition) { mock }

  before do
    strategy_class.should_receive(:new).with(object).and_return(strategy)
    strategy.should_receive(:join).with(other, join_definition).and_return(joined_index)
  end

  it { should be(joined_index) }
end
