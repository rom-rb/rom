require 'spec_helper'

describe Session::Session, '#dirty?' do
  subject { object.dirty?(domain_object) }

  let(:mapper)        { registry.resolve_model(DomainObject) }
  let(:registry)      { DummyRegistry.new                    }
  let(:domain_object) { DomainObject.new                     }
  let(:object)        { described_class.new(registry)        }

  context 'when domain object is tracked' do
    before do
      object.persist(domain_object)
    end


    context 'and domain object is NOT dirty' do
      it { should be(false) }

      it_should_behave_like 'an idempotent method'
    end

    context 'and domain object is dirty' do
      before do
        domain_object.other_attribute = :modified
      end

      it { should be(true) }

      it_should_behave_like 'an idempotent method'
    end
  end

  context 'when domain object is NOT tracked' do
    it 'should raise error' do
      expect { subject }.to raise_error(Session::StateError, "#{domain_object.inspect} is not tracked")
    end
  end
end
