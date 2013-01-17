require 'spec_helper'

describe Attribute, '#load' do
  subject { attribute.load({}) }

  let(:class_under_test) do
    klass = subclass(:TestAttribute)
    klass.class_eval do
      def self.inspect; name; end
    end
    klass
  end

  let(:attribute) { class_under_test.new(:title, EMPTY_HASH) }

  specify do
    expect { subject }.to raise_error(
      NotImplementedError, "TestAttribute#load is not implemented")
  end
end
