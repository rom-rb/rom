require 'spec_helper'

describe Relation::Aliases::AttributeIndex, '#rename' do
  subject { object.rename(aliases) }

  let(:object) { described_class.new(entries, strategy_class) }

  let(:entries) { { initial => current } }
  let(:initial) { attribute_alias(:initial_id, :users) }
  let(:current) { attribute_alias(:current_id, :users) }
  let(:aliases) { { :current_id => renamed_current_id } }

  let(:strategy_class) { mock }

  let(:renamed_entries)    { { initial => renamed_current } }
  let(:renamed_current)    { attribute_alias(renamed_current_id, :users) }
  let(:renamed_current_id) { :renamed_current_id }

  it { should eql(described_class.new(renamed_entries, strategy_class)) }
end
