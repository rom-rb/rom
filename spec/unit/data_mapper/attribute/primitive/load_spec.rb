require 'spec_helper'

describe Rom::Attribute::Primitive, '#load' do
  subject { attribute.load(tuple) }

  let(:attribute) { described_class.new(:title, options) }
  let(:options)   { {} }
  let(:value)     { 'Data Mapping' }
  let(:tuple)     { { :title => value } }

  context "when :field is not set" do
    it { should eql(value) }
  end

  context "when :field is set" do
    let(:options) { { :to => :BookTitle } }
    let(:tuple)   { { :BookTitle => value } }

    it { should eql(value) }
  end
end
