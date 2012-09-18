require 'spec_helper'

describe Session::Registry, '#resolve_model' do
  let(:model)  { DomainObject                         }
  let(:mapper) { DummyMapper                          }
  let(:object) { described_class.new(model => mapper) }

  subject { object.resolve_model(model) }


  context 'when mapper for model was registred' do
    it 'should return mapper' do
      should be(mapper)
    end

    it_should_behave_like 'an idempotent method'
  end

  context 'when mapper was NOT registred' do
    let(:object) { described_class.new({}) }

    it 'should raise error' do
      expect { subject }.to raise_error(ArgumentError, "mapper for #{model.inspect} is not registred")
    end
  end
end
