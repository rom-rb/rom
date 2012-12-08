require 'spec_helper'

describe DataMapper::Mapper::AttributeSet, '#finalize' do
  subject { attributes.finalize({}) }

  let(:attributes) { described_class.new }
  let(:id)         { mock('id',   :name => :id) }
  let(:name)       { mock('name', :name => :name) }

  before do
    attributes << id << name

    id.should_receive(:finalize)
    name.should_receive(:finalize)
  end

  it { should equal(attributes) }
end
