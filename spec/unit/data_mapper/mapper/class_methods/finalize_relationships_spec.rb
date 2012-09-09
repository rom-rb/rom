require 'spec_helper'

describe DataMapper::Mapper, '.finalize_relationships' do
  it "finalizes its relationship set" do
    described_class.relationships.should_receive(:finalize)
    described_class.finalize_relationships
  end
end
