require 'spec_helper'

describe Header::AttributeIndex, '#join' do
  subject { object.join(other, join_definition) }

  let(:object) { described_class.new(entries, strategy_class) }
  let(:other)  { described_class.new(other_entries, strategy_class) }

  let(:entries)         { { initial       => current } }
  let(:other_entries)   { { other_initial => other_current } }
  let(:initial)         { attribute_alias(:initial_id, :users) }
  let(:current)         { attribute_alias(:current_id, :users) }
  let(:other_initial)   { attribute_alias(:initial_id, :addresses) }
  let(:other_current)   { attribute_alias(:current_id, :addresses) }
  let(:strategy_class)  { Header::JoinStrategy::NaturalJoin }

  before do
    pending 'no relationships yet + this test is too brittle, needs refactoring'
  end

  it { should be('foo') }
end
