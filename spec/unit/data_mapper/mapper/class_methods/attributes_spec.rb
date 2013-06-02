require 'spec_helper'

describe Rom::Mapper, '.attributes' do
  it "returns attribute set" do
    described_class.attributes.should be_instance_of(described_class::AttributeSet)
  end
end
