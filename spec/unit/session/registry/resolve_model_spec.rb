require 'spec_helper'

describe Session::Registry, '#resolve_model' do
  let(:model)  { DomainObject        }
  let(:mapper) { DummyMapper         }
  let(:object) { described_class.new }

  subject { object.resolve_model(model) }


  context 'when mapper for model was registred' do
    before do
      object.register(model, mapper)
    end

    it 'should return mapper' do
      should be(mapper)
    end

    it_should_behave_like 'an idempotent method'
  end

  context 'when mapper was NOT registred' do
    it 'should raise error' do
      expect { subject }.to raise_error(ArgumentError, "mapper for #{model.inspect} is not registred")
    end
  end
end
