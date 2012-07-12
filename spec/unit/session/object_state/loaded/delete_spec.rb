require 'spec_helper'

describe Session::ObjectState::Loaded, '#delete' do
  let!(:object)        { described_class.new(mapper, domain_object) }
  let(:mapper)        { DummyMapper.new                           }
  let(:domain_object) { DomainObject.new(:foo, :bar) }

  subject { object.delete }

  context 'when domain object key was modified after loading' do
    before do
      domain_object.key_attribute = :modified
    end

    it 'should delete object under stored key' do
      subject
      mapper.deletes.should == [:foo]
    end
  end

  context 'when domain object key was NOT modified after loading' do
    it 'should delete object under stored key' do
      subject
      mapper.deletes.should == [:foo]
    end
  end

  it 'should return ObjectState::Forgotten' do
    state = subject
    state.should be_kind_of(Session::ObjectState::Forgotten)
    state.object.should be(domain_object)
  end
end
