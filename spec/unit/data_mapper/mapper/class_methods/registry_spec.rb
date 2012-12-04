require 'spec_helper'

describe Mapper, '.registry' do
  it "returns mapper registry instance" do
    described_class.registry.should be_instance_of(Mapper::Registry)
  end
end
