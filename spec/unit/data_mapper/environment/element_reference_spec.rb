require 'spec_helper'

describe Environment, '#[]' do
  subject { object[model] }

  let(:object)   { described_class.new }
  let(:mapper)   { object.build(model, :test) }
  let(:model)    { mock_model('Test') }

  before do
    mapper
    object.setup(:test).finalize
  end

  it { should be_instance_of(mapper) }

  its(:environment) { should be(object) }
end
