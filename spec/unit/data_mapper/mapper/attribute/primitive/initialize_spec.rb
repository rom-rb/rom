require 'spec_helper'

describe DataMapper::Mapper::Attribute::Primitive, '#initialize' do
  subject { described_class.new(name, options) }

  let(:name)    { :title }
  let(:options) { {} }

  context "when type is provided" do
    let(:options) { { :type => String } }

    its(:type) { should be(String) }
  end

  context "when type is not provided" do
    its(:type) { should be(Object) }
  end

  context "when :to option is not provided  " do
    its(:field) { should be(name) }
  end

  context "when :to option is provided  " do
    let(:options) { { :to => :bookTitle } }

    its(:field) { should be(:bookTitle) }
  end

  context "when :key is not set" do
    it { should_not be_key }
  end

  context "when :key is set" do
    let(:options) { { :key => true } }

    it { should be_key }
  end
end
