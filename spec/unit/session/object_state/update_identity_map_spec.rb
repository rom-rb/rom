require 'spec_helper'

describe Session::ObjectState,'#update_identity_map' do
  let(:object)        { described_class.new(mapper,domain_object) }
  let(:mapper)        { DummyMapper.new                           }
  let(:domain_object) { DomainObject.new(:foo,:bar) }

  let(:identity_map)         { { mapper.dump_key(domain_object) => domain_object }.freeze }

  subject { object.update_identity_map(identity_map) }

  it 'should not touch identity map' do
    subject
  end

  it 'should return self' do
    should be(object)
  end
end
