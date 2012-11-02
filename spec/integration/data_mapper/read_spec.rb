require 'spec_helper'

describe DataMapper::Session, '#read' do
  let(:mapper)        { registry.resolve_model(Spec::DomainObject) }
  let(:registry)      { Spec::Registry.new                         }
  let(:domain_object) { Spec::DomainObject.new                     }
  let(:object)        { described_class.new(registry)              }
  let(:mapper)        { registry.resolve_object(domain_object)     }
  let(:query)         { mock                                       }

  subject { object.read(Spec::DomainObject, query) }

  its(:mapper)  { should be(mapper) }
  its(:query)   { should be(query)  }
  its(:session) { should be(object) }
end
