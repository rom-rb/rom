require 'spec_helper'

describe AttributeSet, '#includes?' do
  subject { attributes.includes?(attribute) }

  let(:attributes) { described_class.new }
  let(:id)         { mock('id',   :name => :id) }
  let(:name)       { mock('name', :name => :name) }

  before { attributes << id }

  context "when attributes include an attribute" do
    let(:attribute) { id }

    it { should be(true) }
  end

  context "when attributes don't include an attribute" do
    let(:attribute) { name }

    it { should be(false) }
  end
end
