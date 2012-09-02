require 'spec_helper'

describe DataMapper::Mapper::AttributeSet, '#each' do
  let(:attributes) { described_class.new }
  let(:id)         { mock('id',   :name => :id) }
  let(:name)       { mock('name', :name => :name) }

  before { attributes << id << name }

  it "yields its attributes" do
    attributes.each.to_a.should eql([ name, id ])
  end
end
