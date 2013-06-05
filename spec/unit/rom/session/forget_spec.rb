require 'spec_helper'

describe ROM::Session, '#forget(object)' do
  let(:mapper)        { registry.resolve_model(Spec::DomainObject) }
  let(:registry)      { Spec::Registry.new                         }
  let(:domain_object) { Spec::DomainObject.new                     }
  let(:object)        { described_class.new(registry)              }

  let(:identity_map)  { object.instance_variable_get(:@tracker).instance_variable_get(:@identities) }

  subject { object.forget(domain_object) }

  it_should_behave_like 'a command method'

  before do
    object.persist(domain_object)
    subject
  end

  it 'should not dump' do
    mapper.should_not_receive(:dumper)
  end

  it 'should remove state' do
    object.include?(domain_object).should be(false)
  end

  it_should_behave_like 'a command method'
end
