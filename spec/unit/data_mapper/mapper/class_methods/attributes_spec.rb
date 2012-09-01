require 'spec_helper'

describe DataMapper::Mapper, '.attributes' do
  it "returns attribute set" do
    described_class.attributes.should be_instance_of(described_class::AttributeSet)
  end
end
