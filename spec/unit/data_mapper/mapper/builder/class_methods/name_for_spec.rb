require 'spec_helper'

describe Mapper::Builder, '.name_for' do
  subject { described_class.name_for(model) }

  let(:model) { mock_model("TestModel") }

  it { should eql('TestModelMapper') }
end
