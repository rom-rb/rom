require 'spec_helper'

describe Session::Session, '#update(object)' do
  let(:mapper)        { registry.resolve_model(DomainObject) }
  let(:registry)      { DummyRegistry.new                    }
  let(:domain_object) { DomainObject.new                     }
  let(:object)        { described_class.new(registry)        }

  subject { object.update(domain_object) }

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
      object.insert(domain_object).commit
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

      it_should_behave_like 'an update registration'

      it 'should unregister delete' do
        subject
        object.delete?(domain_object).should be_false
      end
    end
  end
end
