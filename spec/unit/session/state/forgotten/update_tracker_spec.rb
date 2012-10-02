require 'spec_helper'

describe Session::State::Forgotten, '#update_tracker' do
  subject { object.update_tracker(tracker) }

  let(:key)           { mapper.dump_key(domain_object)         }
  let(:object)        { described_class.new(domain_object, key) }
  let(:mapper)        { DummyMapper.new                        }
  let(:domain_object) { DomainObject.new(:foo, :bar)            }

  let(:tracker)       { { domain_object => object } }

  it_should_behave_like 'a command method'

  it 'should delete object from tracker' do
    subject
    tracker.should == {}
  end

  it 'should return self' do
    should be(object)
  end
end
