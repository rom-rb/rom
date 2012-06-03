require 'spec_helper'

describe Session::ObjectState::Loaded,'#delete' do
  let(:object)        { described_class.new(mapper,domain_object) }
  let(:mapper)        { DummyMapper.new                           }
  let(:domain_object) { DomainObject.new(:foo,:bar) }

  subject { object.delete }

  it 'should delete object' do
    subject
    mapper.deletes.should == [object.remote_key]
  end

  it 'should return ObjectState::Abandoned' do
    state = subject
    state.should be_kind_of(Session::ObjectState::Abandoned)
    state.object.should be(domain_object)
  end
end
