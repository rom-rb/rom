require 'spec_helper'

describe DataMapper::Mapper::Attribute, '#load' do
  subject { attribute.load({}) }

  let(:attribute) { described_class.new(:title) }

  specify do
    expect { subject }.to raise_error(
      NotImplementedError, "#{described_class} must implement #load")
  end
end
