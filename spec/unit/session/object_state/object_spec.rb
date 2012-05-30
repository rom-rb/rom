require 'spec_helper'

describe Session::ObjectState,'#object' do
  let(:object)        { described_class.new(mapper,domain_object) }
  let(:mapper)        { DummyMapper.new                           }
  let(:domain_object) { DomainObject.new(:foo,:bar) }

  subject { object.object }

  it 'should return domain object' do
    should == domain_object
  end
end
