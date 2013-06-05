require 'spec_helper'

describe ROM::Session, '#dirty?' do
  subject { object.dirty?(domain_object) }

  let(:mapper)        { registry.resolve_model(Spec::DomainObject) }
  let(:registry)      { Spec::Registry.new                         }
  let(:domain_object) { Spec::DomainObject.new                     }
  let(:object)        { described_class.new(registry)              }

  context 'when domain object is tracked' do
    before do
      object.persist(domain_object)
    end


    context 'and domain object is NOT dirty' do
      it { should be(false) }

      it_should_behave_like 'an idempotent method'
      it_should_behave_like 'an operation that dumps once'
    end

    context 'and domain object is dirty' do
      before do
        domain_object.other_attribute = :modified
      end

      it { should be(true) }

      it_should_behave_like 'an idempotent method'
      it_should_behave_like 'an operation that dumps once'
    end
  end

  context 'when domain object is NOT tracked' do
    it 'should raise error' do
      expect { subject }.to raise_error(ROM::Session::StateError, "#{domain_object.inspect} is not tracked")
    end
  end
end
