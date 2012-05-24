require 'spec_helper'

describe Session::Session, '#delete(object)' do
  let(:mapper)        { registry.resolve_model(DomainObject) }
  let(:registry)      { DummyRegistry.new                    }
  let(:domain_object) { DomainObject.new                     }
  let(:object)        { described_class.new(registry)        }

  subject { object.delete(domain_object) }

  shared_examples_for 'a delete registration' do
    it 'should mark domain object as to be deleted' do
      subject
      object.delete?(domain_object).should be_true
    end

    it 'should track domain object' do
      object.track?(domain_object).should be_true
    end
  end

  shared_examples_for 'a failing delete registration' do
    it 'should raise error' do
      expect { subject }.to raise_error
    end
  end

  context 'when domain object was not tracked' do
    it_should_behave_like 'a failing delete registration'
  end

  context 'when domain object was tracked' do
    before do
      object.insert(domain_object).commit
    end

    context 'when was NOT marked as delete' do
      it 'should NOT be marked as delete' do
        object.delete?(domain_object).should be_false
      end

      it_should_behave_like 'a delete registration'
    end

    context 'when was marked as update' do
      before do
        object.update(domain_object)
      end

      it_should_behave_like 'a delete registration'

      it 'should unregister update' do
        object.update?(domain_object).should be_true
      end
    end
  end
end
