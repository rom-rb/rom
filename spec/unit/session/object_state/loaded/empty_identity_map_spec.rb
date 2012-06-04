require 'spec_helper'

describe Session::ObjectState::Loaded,'#empty_identity_map' do
  let(:object)        { described_class.new(mapper,domain_object) }
  let(:mapper)        { DummyMapper.new                           }
  let(:domain_object) { DomainObject.new(:foo,:bar) }

  let(:identity_map)         { { mapper.dump_key(domain_object) => domain_object } }

  subject { object.empty_identity_map(identity_map) }

  it 'should remove object from identity_map' do
    subject
    identity_map.should == {}
  end

  it 'should return self' do
    should be(object)
  end
end
