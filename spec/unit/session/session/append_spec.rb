require 'spec_helper'

describe Session::Session, '#<<(object)' do
  let(:mapper)        { registry.resolve_model(DomainObject) }
  let(:registry)      { DummyRegistry.new                    }
  let(:domain_object) { DomainObject.new                     }
  let(:object)        { described_class.new(registry)        }

  subject { object << domain_object }

  it_should_behave_like 'a command method'

  it 'should delegate to #persist' do
    object.should_receive(:persist).with(domain_object)
    subject
  end
end
