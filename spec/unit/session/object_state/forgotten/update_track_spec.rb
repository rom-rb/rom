require 'spec_helper'

describe Session::ObjectState::Forgotten,'#update_track' do
  let(:key)           { mapper.dump_key(domain_object)         }
  let(:object)        { described_class.new(domain_object,key) }
  let(:mapper)        { DummyMapper.new                        }
  let(:domain_object) { DomainObject.new(:foo,:bar)            }

  let(:track)         { { domain_object => object } }

  subject { object.update_track(track) }

  it_should_behave_like 'a command method'

  it 'should delete object from track' do
    subject
    track.should == {}
  end

  it 'should return self' do
    should be(object)
  end
end
