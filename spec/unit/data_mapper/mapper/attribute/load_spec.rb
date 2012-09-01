require 'spec_helper'

describe DataMapper::Mapper::Attribute, '#load' do
  let(:attribute) { described_class.new(:title) }

  specify do
    expect { attribute.load({}).to raise_error(
      NotImplementedError, "#{described_class} must implement #load")}
  end
end
