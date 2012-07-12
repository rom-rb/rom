require 'spec_helper'

describe Session::ObjectState, '#dump' do
  let(:object)        { described_class.new(mapper, domain_object) }
  let(:mapper)        { DummyMapper.new                           }
  let(:domain_object) { DomainObject.new(:foo, :bar) }

  subject do
    object.dump
  end

  it 'should return dump representation' do
    should == {
      :key_attribute => :foo, 
      :other_attribute => :bar
    }
  end
end
