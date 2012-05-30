require 'spec_helper'

describe Session::ObjectState::Abandoned,'#update_track' do
  let(:key)           { mapper.dump_key(domain_object)         }
  let(:object)        { described_class.new(domain_object,key) }
  let(:mapper)        { DummyMapper.new                        }
  let(:domain_object) { DomainObject.new(:foo,:bar)            }

  let(:track)         { { domain_object => object } }

  subject { object.update_track(track) }

  it 'should delete object from track' do
    subject
    track.should == {}
  end

  it 'should return self' do
    subject.should == object
  end
end
