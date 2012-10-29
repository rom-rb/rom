require 'spec_helper'

describe DataMapper::Mapper::Builder::Class, '.name_for' do
  subject { described_class.name_for(model) }

  let(:model) { mock_model("TestModel") }

  it { should eql('TestModelMapper') }
end
