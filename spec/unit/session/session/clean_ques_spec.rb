require 'spec_helper'

describe Session::Session,'#clean?(object)' do
  let(:mapper)        { registry.resolve_model(DomainObject) }
  let(:registry)      { DummyRegistry.new                    }
  let(:domain_object) { DomainObject.new                     }
  let(:object)        { described_class.new(registry)        }

  subject { object.clean?(domain_object) }

  context 'when domain object is tracked' do
    before do 
      object.insert(domain_object)
    end

    context 'and domain object is NOT clean' do
      before do
        domain_object.other_attribute = :modified
      end

      it { should be_false }
    end

    context 'and domain object is clean' do
      it { should be_true }
    end
  end

  context 'when domain object is NOT tracked' do
    it 'should raise error' do
      expect { subject }.to raise_error
    end
  end
end
