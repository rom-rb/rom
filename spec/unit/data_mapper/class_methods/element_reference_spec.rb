require 'spec_helper'

describe DataMapper, '.[]' do
  subject { DataMapper[model] }

  let(:model)  { mock('model') }
  let(:mapper) { mock('mapper') }

  before { Mapper.should_receive(:[]).with(model).and_return(mapper) }

  it { should be(mapper) }
end
