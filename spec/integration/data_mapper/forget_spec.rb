require 'spec_helper'

describe DataMapper::Session, '#forget(object)' do
  let(:mapper)        { registry.resolve_model(DomainObject) }
  let(:registry)      { DummyRegistry.new                    }
  let(:domain_object) { DomainObject.new                     }
  let(:object)        { described_class.new(registry)        }

  let(:identity_map)  { object.instance_variable_get(:@tracker).instance_variable_get(:@identities) }

  subject { object.forget(domain_object) }

  it_should_behave_like 'a command method'

  before do
    object.persist(domain_object)
    subject
  end

  it 'should not dump' do
    mapper.should_not_receive(:dump)
    mapper.should_not_receive(:dump_key)
  end

  it 'should remove state' do
    object.include?(domain_object).should be(false)
  end

  it 'should remove from identity map' do
    identity_map.should_not have_key(mapper.dump_key(domain_object))
  end

  it_should_behave_like 'a command method'
end
