require 'spec_helper'

describe Session::ObjectState::Loaded,'#delete_identity' do
  let(:object)        { described_class.new(mapper,domain_object) }
  let(:mapper)        { DummyMapper.new                           }
  let(:domain_object) { DomainObject.new(:foo,:bar) }

  let(:identity_map)         { { mapper.dump_key(domain_object) => domain_object } }

  subject { object.delete_identity(identity_map) }

  it 'should remove object from identity_map' do
    subject
    identity_map.should == {}
  end

  it 'should return self' do
    should be(object)
  end
end
