require 'spec_helper'

describe Session::ObjectState::Loaded, '.build' do
  let(:object)        { described_class                      }
  let(:mapper)        { registry.resolve_model(DomainObject) }
  let(:registry)      { DummyRegistry.new                    }
  let(:domain_object) { DomainObject.new                     }
  let(:dump)          { mapper.dump(domain_object)           }

  let(:subject) { object.build(mapper, dump) }

  it 'should load object and initialized object state' do
    state = subject
    state.should be_kind_of(described_class)
    state.object.should be_kind_of(DomainObject)
    state.object.key_attribute.should == domain_object.key_attribute
    state.object.other_attribute.should == domain_object.other_attribute
  end
end
