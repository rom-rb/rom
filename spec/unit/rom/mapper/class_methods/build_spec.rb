# encoding: utf-8

require 'spec_helper'

describe Mapper, '.build' do
  subject { described_class.build(header, model, options) }

  let(:model)      { mock_model(:name) }
  let(:attributes) { [[:user_name, String]] }
  let(:options)    { Hash[map: { user_name: :name }] }

  describe 'when header is a primitive' do
    let(:header) { attributes }

    its(:model)  { should be(model) }
    its(:loader) { should be_instance_of(Mapper::Loader) }
    its(:dumper) { should be_instance_of(Mapper::Dumper) }

    it 'builds correct header' do
      expect(subject.header.mapping).to eql(options[:map])
    end

    let(:object) { model.new(name: 'Jane') }
    let(:params) { Hash[name: 'Jane'] }

    specify do
      expect(subject.load(params)).to eq(object)
    end

    specify do
      expect(subject.dump(object)).to eq(params.values)
    end
  end

  describe 'when header is a mapper header instance' do
    let(:header)  { Mapper::Header.build(attributes) }
    let(:options) { Hash.new }

    its(:model)  { should be(model) }
    its(:loader) { should be_instance_of(Mapper::Loader) }
    its(:dumper) { should be_instance_of(Mapper::Dumper) }
    its(:header) { should be(header) }
  end

  describe 'when options has custom loader' do
    let(:header)  { Mapper::Header.build(attributes) }
    let(:options) { Hash[loader: :load_attribute_hash] }

    its(:model)  { should be(model) }
    its(:loader) { should be_instance_of(Mapper::Loader) }
    its(:dumper) { should be_instance_of(Mapper::Dumper) }
    its(:header) { should be(header) }
  end

  describe 'loader is set to :load_attribute_accessors' do
    let(:header)  { Mapper::Header.build(attributes) }
    let(:options) { Hash[loader: :load_attribute_accessors] }

    its(:model)  { should be(model) }
    its(:loader) { should be_instance_of(Mapper::Loader) }
    its(:dumper) { should be_instance_of(Mapper::Dumper) }
    its(:header) { should be(header) }
  end
end
