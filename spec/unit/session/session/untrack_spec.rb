require 'spec_helper'

describe Session::Session,'#untrack(object)' do
  let(:mapper)        { registry.resolve_model(DomainObject) }
  let(:registry)      { DummyRegistry.new                    }
  let(:domain_object) { DomainObject.new                     }
  let(:object)        { described_class.new(registry)        }

  let(:identity_map)  { object.instance_variable_get(:@identity_map) }

  subject { object.untrack(domain_object) }

  shared_examples_for 'an untrack operation' do
    it 'should remove state' do
      object.track?(domain_object).should be_false
    end

    it 'should remove from identity map' do
      identity_map.should_not have_key(mapper.dump_key(domain_object))
    end
  end

  context 'when domain object is tracked' do
    before do 
      object.insert(domain_object)
      subject
    end

    it_should_behave_like 'an untrack operation'
  end

  context 'when domain object is NOT tracked' do
    before do
      subject
    end

    it_should_behave_like 'an untrack operation'
  end
end
