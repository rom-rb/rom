require 'spec_helper'

describe Session::Operation,'#run' do
  let(:domain_object) { mock }
  let(:registry) { mock }
  let(:object) { described_class.new(registry,domain_object) }

  subject { object.run }

  it 'should raise error' do
    expect { subject }.to raise_error
  end
end

