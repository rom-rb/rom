require 'spec_helper'

describe Session::Session, '#update(object)' do
  let(:mapper)  { DummyMapper.new  }
  let(:root)    { DummyMapperRoot.new(mapper)  }

  let(:object) do 
    described_class.new(
      :root => root
    )
  end

  let(:domain_object) { DomainObject.new }

  subject { object.update(domain_object) }

  shared_examples_for 'an update registration' do
    it 'should mark domain object as to be updated' do
      subject
      object.update?(domain_object).should be_true
    end

    it 'should track domain object' do
      object.track?(domain_object).should be_true
    end
  end

  shared_examples_for 'a failing update registration' do
    it 'should raise error' do
      expect { subject }.to raise_error
    end
  end

  context 'when domain object was not tracked' do
    it_should_behave_like 'a failing update registration'
  end

  context 'when domain object was tracked' do
    before do
      object.insert_now(domain_object)
    end

    context 'when was NOT marked as update' do
      it 'should NOT be marked as update' do
        object.update?(domain_object).should be_false
      end

      it_should_behave_like 'an update registration'
    end

    context 'when was marked as delete' do
      before do
        object.delete(domain_object)
      end
      it_should_behave_like 'a failing update registration'
    end
  end
end
