require 'spec_helper'

describe DataMapper::Mapper::AttributeSet, '#finalize' do
  let(:attributes) { described_class.new }
  let(:id)         { mock('id',   :name => :id) }
  let(:name)       { mock('name', :name => :name) }

  before { attributes << id << name }

  it "finalizes its attributes" do
    id.should_receive(:finalize)
    name.should_receive(:finalize)

    attributes.finalize
  end
end
