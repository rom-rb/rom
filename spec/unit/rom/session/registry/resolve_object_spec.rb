require 'spec_helper'

describe ROM::Session::Registry, '#resolve_object' do

  let(:model)         { Spec::DomainObject                   }
  let(:mapper)        { Spec::Mapper                         }
  let(:object)        { described_class.new(model => mapper) }
  let(:domain_object) { Spec::DomainObject.new               }

  subject { object.resolve_object(domain_object) }

  context 'when mapper for model was registered' do
    it 'should return mapper' do
      should be(mapper)
    end

    it_should_behave_like 'an idempotent method'
  end

  context 'when mapper was NOT registred' do
    let(:domain_object) { Object.new }

    it 'should raise error' do
      expect { subject }.to raise_error(ROM::Session::MissingMapperError, "Mapper for: #{domain_object.class.inspect} is not registered")
    end
  end
end
