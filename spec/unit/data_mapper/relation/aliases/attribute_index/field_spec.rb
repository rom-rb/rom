require 'spec_helper'

describe Relation::Aliases::AttributeIndex, '#field' do
  subject { object.field(name) }

  let(:object) { described_class.new(entries, strategy_class) }

  let(:entries)        { { initial => current } }
  let(:initial)        { attribute_alias(:id, :users) }
  let(:current)        { attribute_alias(:current_id, :users) }
  let(:strategy_class) { mock }

  context "when the requested name is present" do
    let(:name) { :id }

    it { should be(current) }
  end

  context "when the requested name is not present" do
    let(:name) { mock }

    it "should raise KeyError" do
      expect { subject.to_raise_error(KeyError) }
    end
  end
end
