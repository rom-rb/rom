require 'spec_helper'

describe Header::AttributeIndex, '#aliases' do
  subject { object.aliases(other) }

  let(:object) { described_class.new(entries, strategy_class) }

  let(:entries)         { { initial       => current } }
  let(:initial)         { attribute_alias(:initial_id, :users) }
  let(:current)         { attribute_alias(:current_id, :users) }
  let(:strategy_class) { Class.new }

  context "when self.eql(other)" do
    let(:other) { object }

    it { should eql({}) }
  end

  context "when !self.eql(other)" do
    let(:other)         { described_class.new(other_entries, strategy_class) }
    let(:other_entries) { { other_initial => other_current } }
    let(:other_initial) { attribute_alias(:initial_id,       :users) }
    let(:other_current) { attribute_alias(:other_current_id, :users) }

    it { should eql(:current_id => :other_current_id) }
  end
end
