require 'spec_helper'

describe Session::ObjectState,'#key' do
  let(:object)        { described_class.new(mapper,domain_object) }
  let(:mapper)        { DummyMapper.new                           }
  let(:domain_object) { DomainObject.new(:foo,:bar) }

  subject do
    object.key
  end

  it 'should return dumped key representation' do
    should == :foo
  end
end
