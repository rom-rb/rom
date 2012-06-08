require 'spec_helper'

describe Session::ObjectState,'#update_track' do
  let(:object)        { described_class.new(mapper,domain_object) }
  let(:mapper)        { DummyMapper.new                           }
  let(:domain_object) { DomainObject.new(:foo,:bar) }

  let(:track)         { {}.freeze }

  subject { object.update_track(track) }

  it_should_behave_like 'a command method'

  it 'should not touch track' do
    subject
  end

  it 'should return self' do
    should be(object)
  end
end
