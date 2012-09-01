require 'spec_helper'

describe DataMapper::Mapper::Attribute::Primitive, '#header' do
  subject { attribute.header }

  let(:attribute) { described_class.new(name, options) }
  let(:name)      { :title }
  let(:type)      { String }

  context "when :to is not provided" do
    let(:options) { { :type => type } }

    it { should eql([ name, type ])}
  end

  context "when :to is provided" do
    let(:field)   { :BookTitle }
    let(:options) { { :type => type, :to => field } }

    it { should eql([ field, type ])}
  end
end
