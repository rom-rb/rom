require 'spec_helper'

describe DataMapper::MapperRegistry, '#[]' do
  subject { registry[model] }

  let(:model)    { mock_model('TestModel') }
  let(:mapper)   { mock_mapper(model).new  }
  let(:registry) { described_class.new     }

  before { registry << mapper }

  it { should be(mapper) }
end
