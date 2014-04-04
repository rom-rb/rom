# encoding: utf-8

require 'spec_helper'

describe Mapper, '.build' do
  subject { described_class.build(header, model: model) }

  let(:model)      { mock_model(:name) }
  let(:attributes) { [[:name, type: String, from: :user_name]] }

  describe 'when header is a primitive' do
    let(:header) { attributes }

    its(:model)  { should be(model) }

    it 'builds correct header' do
      expect(subject.header.mapping).to eql(user_name: :name)
    end

    let(:object) { model.new(name: 'Jane') }
    let(:params) { Hash[user_name: 'Jane'] }

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
    its(:header) { should eql(header) }
  end

  describe 'when options has custom loader' do
    let(:header)  { Mapper::Header.build(attributes) }
    let(:options) { Hash[loader: :load_attribute_hash] }

    its(:model)  { should be(model) }
    its(:header) { should eql(header) }
  end

  describe 'loader is set to :load_attribute_accessors' do
    let(:header)  { Mapper::Header.build(attributes) }
    let(:options) { Hash[loader: :load_attribute_accessors] }

    its(:model)  { should be(model) }
    its(:header) { should eql(header) }
  end
end
