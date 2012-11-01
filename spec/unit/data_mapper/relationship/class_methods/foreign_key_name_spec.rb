require 'spec_helper'

describe Relationship, '.foreign_key_name' do
  subject { described_class.foreign_key_name(class_name) }

  let(:class_name) { stub }
  let(:fk_string)  { stub }

  it "delegates to Inflector and calls #to_sym on the result" do
    Inflector.should_receive(:foreign_key).with(class_name).and_return(fk_string)
    fk_string.should_receive(:to_sym)
    subject
  end
end
