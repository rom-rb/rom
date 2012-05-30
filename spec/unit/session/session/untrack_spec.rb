require 'spec_helper'

describe Session::Session,'#untrack(object)' do
  let(:mapper)        { registry.resolve_model(DomainObject) }
  let(:registry)      { DummyRegistry.new                    }
  let(:domain_object) { DomainObject.new                     }
  let(:object)        { described_class.new(registry)        }

  let(:identity_map)  { object.instance_variable_get(:@identity_map) }

  subject { object.untrack(domain_object) }

  before do 
    object.insert(domain_object)
    subject
  end

  it 'should remove state' do
    object.track?(domain_object).should be_false
  end

  it 'should remove from identity map' do
    identity_map.should_not have_key(mapper.dump_key(domain_object))
  end
end
