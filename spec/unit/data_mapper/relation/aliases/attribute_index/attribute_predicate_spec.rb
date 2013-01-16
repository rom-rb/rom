require 'spec_helper'

describe Relation::Aliases::AttributeIndex, '#attribute?' do
  subject { object.attribute?(name) }

  let(:object) { described_class.new(entries, strategy_class) }

  let(:entries)        { { initial => current } }
  let(:initial)        { attribute_alias(:id, :users) }
  let(:current)        { attribute_alias(:id, :users) }
  let(:strategy_class) { mock }

  context "when the requested name is present" do
    let(:name) { :id }

    it { should be(true) }
  end

  context "when the requested name is not present" do
    let(:name) { mock }

    it { should be(false) }
  end
end
