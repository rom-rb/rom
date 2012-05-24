require 'spec_helper'

describe Session::Session,'#untrack(object)' do
  let(:mapper)        { registry.resolve_model(DomainObject) }
  let(:registry)      { DummyRegistry.new                    }
  let(:domain_object) { DomainObject.new                     }
  let(:object)        { described_class.new(registry)        }

  subject { object.untrack(domain_object) }

  context 'when domain object is tracked' do
    before do 
      object.insert(domain_object).commit
      subject
    end

    it 'should untrack object' do
      subject
      object.track?(domain_object).should be_false
    end
  end


  context 'when domain object is NOT tracked' do
    it 'should not fail' do
      subject
      object.track?(domain_object).should be_false
    end
  end
end
