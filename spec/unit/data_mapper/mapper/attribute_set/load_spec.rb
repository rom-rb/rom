require 'spec_helper'

describe DataMapper::Mapper::AttributeSet, '#load' do
  subject { attributes.load(tuple) }

  let(:attributes) { described_class.new }

  let(:id)   { mock('id',   :name => :id) }
  let(:name) { mock('name', :name => :name) }

  let(:tuple) { { :id => '1', :name => 'John' } }

  before { attributes << id << name }

  it "loads tuple using attributes" do
    id.should_receive(:load).with(tuple).and_return(1)
    name.should_receive(:load).with(tuple).and_return('John')

    subject.should eql({ :id => 1, :name => 'John' })
  end
end
