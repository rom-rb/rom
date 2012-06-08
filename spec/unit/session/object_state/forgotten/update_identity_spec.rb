require 'spec_helper'

describe Session::ObjectState::Forgotten,'#update_identity' do
  let(:key)           { mapper.dump_key(domain_object)         }
  let(:object)        { described_class.new(domain_object,key) }
  let(:mapper)        { DummyMapper.new                        }
  let(:domain_object) { DomainObject.new(:foo,:bar)            }

  let(:identity_map)  { { key => domain_object } }

  subject { object.update_identity(identity_map) }

  it_should_behave_like 'a command method'

  it 'should delete object from identity map' do
    subject
    identity_map.should == {}
  end

  it 'should return self' do
    should be(object)
  end
end
