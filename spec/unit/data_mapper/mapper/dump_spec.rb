require 'spec_helper'

describe DataMapper::Mapper, '#dump' do
  subject { mapper.dump({}) }

  let(:mapper) { described_class.new }

  specify do
    expect { subject }.to raise_error(
      NotImplementedError, "#{described_class} must implement #dump")
  end
end
