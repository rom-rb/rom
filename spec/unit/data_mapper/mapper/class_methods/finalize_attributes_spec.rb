require 'spec_helper'

describe DataMapper::Mapper, '.finalize_attributes' do
  it "finalizes its attribute set" do
    described_class.attributes.should_receive(:finalize).with({})
    described_class.finalize_attributes({})
  end
end
