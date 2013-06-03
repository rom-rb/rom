require 'spec_helper'

describe ROM::Mapper, '.finalize_attributes' do
  subject { object.finalize_attributes(registry) }

  let(:object)   { described_class }
  let(:registry) { mock }

  before do
    object.attributes.should_receive(:finalize).with(registry)
  end

  it_should_behave_like 'a command method'
end
