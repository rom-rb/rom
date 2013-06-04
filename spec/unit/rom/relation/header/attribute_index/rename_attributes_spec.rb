require 'spec_helper'

describe Relation::Header::AttributeIndex, '#rename_attributes' do
  subject { object.rename_attributes(aliases) }

  let(:object) { described_class.new(entries, strategy_class) }

  let(:entries) { { initial => current } }
  let(:initial) { attribute_alias(:initial_id, :users) }
  let(:current) { attribute_alias(:current_id, :users) }

  let(:strategy_class) { mock }

  context "when the field to rename is indexed" do
    let(:aliases) { { :current_id => renamed_current_id } }

    let(:renamed_entries)    { { initial => renamed_current } }
    let(:renamed_current)    { attribute_alias(renamed_current_id, :users) }
    let(:renamed_current_id) { :renamed_current_id }

    it { should eql(described_class.new(renamed_entries, strategy_class)) }
  end

  context "when the field to rename is not indexed" do
    let(:aliases) { { mock => :current_id } }

    it { should eql(described_class.new(entries, strategy_class)) }
  end
end
