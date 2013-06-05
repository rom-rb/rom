require 'spec_helper'

describe ROM::Session, '#delete' do
  let(:mapper)        { registry.resolve_model(Spec::DomainObject)   }
  let(:registry)      { Spec::Registry.new                           }
  let(:domain_object) { Spec::DomainObject.new                       }
  let(:object)        { described_class.new(registry)                }
  let(:state)       { ROM::Session::State.new(mapper, domain_object) }

  let(:identity_map)  { object.instance_variable_get(:@tracker).instance_variable_get(:@identities) }

  subject { object.delete(domain_object) }

  let!(:identity) { mapper.dumper(domain_object).identity }

  context 'when domain object is tracked' do
    before do
      object.persist(domain_object)
    end

    it 'should delete object' do
      subject
      mapper.deletes.should eql([ROM::Session::Operand.new(state)])
    end

    it 'should not track object anymore' do
      subject
      object.include?(domain_object).should be(false)
    end

    it_should_behave_like 'a command method'
    it_should_behave_like 'an operation that dumps once'
  end

  context 'when domain object is NOT tracked' do
    it 'should raise error' do
      expect { subject }.to raise_error(ROM::Session::StateError, "#{domain_object.inspect} is not tracked")
    end
  end
end
