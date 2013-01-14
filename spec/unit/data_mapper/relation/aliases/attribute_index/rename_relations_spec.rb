require 'spec_helper'

describe Relation::Aliases::AttributeIndex, '#rename_relations' do
  subject { object.rename_relations(aliases) }

  let(:object) { described_class.new(entries, strategy_class) }

  let(:entries) { { initial => current } }
  let(:initial) { attribute_alias(:initial_id, :users) }
  let(:current) { attribute_alias(:current_id, :users) }
  let(:aliases) { { :users => :people } }

  let(:strategy_class) { mock }

  let(:renamed_entries) { { renamed_initial => renamed_current } }
  let(:renamed_initial) { attribute_alias(:initial_id, :people) }
  let(:renamed_current) { attribute_alias(:current_id, :people) }

  it { should eql(described_class.new(renamed_entries, strategy_class)) }
end
