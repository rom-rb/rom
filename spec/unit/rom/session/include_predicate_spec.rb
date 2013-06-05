require 'spec_helper'

describe ROM::Session, '#include?(object)' do
  let(:mapper)        { registry.resolve_model(Spec::DomainObject) }
  let(:registry)      { Spec::Registry.new                         }
  let(:domain_object) { Spec::DomainObject.new                     }
  let(:object)        { described_class.new(registry)              }

  subject { object.include?(domain_object) }


  context 'when domain object is tracked' do
    before do
      object.persist(domain_object)
    end

    it { should be(true) }

    it_should_behave_like 'an idempotent method'
  end

  context 'when domain object is NOT tracked' do
    it { should be(false) }

    it_should_behave_like 'an idempotent method'
  end
end
