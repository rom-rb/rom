require 'spec_helper'

describe DataMapper::Mapper::Attribute, '#load' do
  subject { attribute.load({}) }

  let(:attribute) { subclass(:TestAttribute).new(:title) }

  specify do
    expect { subject }.to raise_error(
      NotImplementedError, "TestAttribute#load is not implemented")
  end
end
