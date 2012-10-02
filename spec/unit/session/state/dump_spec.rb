require 'spec_helper'

describe Session::State, '#dump' do
  subject { object.dump }

  let(:class_under_test) do
    Class.new(described_class)
  end

  let(:object)        { class_under_test.new(mapper, domain_object) }
  let(:mapper)        { DummyMapper.new                             }
  let(:domain_object) { DomainObject.new(:foo, :bar)                }

  it 'should return dump representation' do
    should == {
      :key_attribute => :foo, 
      :other_attribute => :bar
    }
  end
end
