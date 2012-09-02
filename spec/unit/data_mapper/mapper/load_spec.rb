require 'spec_helper'

describe DataMapper::Mapper, '#load' do
  subject { mapper.load({}) }

  let(:mapper) { described_class.new }

  specify do
    expect { subject }.to raise_error(
      NotImplementedError, "#{described_class} must implement #load")
  end
end
