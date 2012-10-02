require 'spec_helper'

describe Session::State::Loaded, '#update_tracker' do
  let(:tracker)       { {} }

  let(:object)        { described_class.new(mapper, domain_object) }
  let(:mapper)        { DummyMapper.new                           }
  let(:domain_object) { DomainObject.new(:foo, :bar) }


  subject { object.update_tracker(tracker) }

  it_should_behave_like 'a command method'

  it 'should add object to tracker' do
    subject
    tracker.should == { domain_object => object }
  end

  it 'should return self' do
    should be(object)
  end
end
