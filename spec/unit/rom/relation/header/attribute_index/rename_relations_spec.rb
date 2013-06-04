require 'spec_helper'

describe Relation::Header::AttributeIndex, '#rename_relations' do
  subject { object.rename_relations(aliases) }

  let(:object) { described_class.new(entries, strategy_class) }

  let(:entries) { { initial => current } }
  let(:initial) { attribute_alias(:initial_id, :users) }
  let(:current) { attribute_alias(:current_id, :users) }

  let(:strategy_class) { mock }

  context "when the relation to rename is indexed" do
    let(:aliases) { { :users => :people } }

    let(:renamed_entries) { { renamed_initial => renamed_current } }
    let(:renamed_initial) { attribute_alias(:initial_id, :people) }
    let(:renamed_current) { attribute_alias(:current_id, :people) }

    it { should eql(described_class.new(renamed_entries, strategy_class)) }
  end

  context "when the relation to rename is not indexed" do
    let(:aliases) { { mock => :people } }

    it { should eql(described_class.new(entries, strategy_class)) }
  end
end
