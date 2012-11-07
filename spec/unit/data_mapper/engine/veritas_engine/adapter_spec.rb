require 'spec_helper'

describe Engine::VeritasEngine, '#adapter' do
  subject { object.adapter }

  let(:object) { described_class.new(uri)    }
  let(:uri)    { "postgres://localhost/test" }

  it 'instantiates Veritas::Adapter::DataObjects with the proper uri' do
    Veritas::Adapter::DataObjects.should_receive(:new).with(uri)
    subject
  end

  it { should be_instance_of(Veritas::Adapter::DataObjects) }
end
