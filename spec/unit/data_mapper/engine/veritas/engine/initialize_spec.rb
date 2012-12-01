require 'spec_helper'

describe Engine::Veritas::Engine, '#initialize' do
  subject { described_class.new(uri) }

  let(:uri) { "postgres://localhost/test" }

  it 'instantiates Veritas::Adapter::DataObjects with the proper uri' do
    Veritas::Adapter::DataObjects.should_receive(:new).with(uri)
    subject
  end

  its(:adapter) { should be_instance_of(Veritas::Adapter::DataObjects) }
end
