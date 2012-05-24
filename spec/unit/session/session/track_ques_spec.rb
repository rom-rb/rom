require 'spec_helper'

describe Session::Session,'#track?(object)' do
  let(:mapper)        { registry.resolve_model(DomainObject) }
  let(:registry)      { DummyRegistry.new                    }
  let(:domain_object) { DomainObject.new                     }
  let(:object)        { described_class.new(registry)        }

  subject { object.track?(domain_object) }

  context 'when domain object is tracked' do
    before do 
      object.insert(domain_object).commit
    end

    it { should be_true }
  end

  context 'when domain object is NOT tracked' do
    it { should be_false }
  end
end
