require 'spec_helper'

describe Environment, '#build' do
  subject { object.build(model, repository) }

  let(:object)     { described_class.new }
  let(:model)      { mock_model('User') }
  let(:repository) { :test }
  let(:mapper)     { mock('mapper') }
  let(:engine)     { mock('engine') }

  before do
    object.engines[:test] = engine
  end

  it 'builds mapper class' do
    subject.should be < Relation::Mapper
    subject.engine.should be(engine)
    subject.environment.should be(object)
  end
end
