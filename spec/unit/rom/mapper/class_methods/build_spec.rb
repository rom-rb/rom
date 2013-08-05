require 'spec_helper'

describe Mapper, '.build' do
  subject { described_class.build(header, model, options) }

  let(:model)      { mock_model(:name) }
  let(:attributes) { [[:user_name, String]] }
  let(:options)    { Hash[map: { user_name: :name }] }

  describe 'when header is a primitive' do
    let(:header) { attributes }

    its(:model)  { should be(model) }
    its(:loader) { should be_instance_of(Mapper::DEFAULT_LOADER) }
    its(:dumper) { should be_instance_of(Mapper::DEFAULT_DUMPER) }

    it 'builds correct header' do
      expect(subject.header.mapping).to eql(options[:map])
    end
  end

  describe 'when header is a mapper header instance' do
    let(:header)  { Mapper::Header.build(attributes) }
    let(:options) { Hash.new }

    its(:model)  { should be(model) }
    its(:loader) { should be_instance_of(Mapper::DEFAULT_LOADER) }
    its(:dumper) { should be_instance_of(Mapper::DEFAULT_DUMPER) }
    its(:header) { should be(header) }
  end

  describe 'when options has custom loader' do
    let(:header)  { Mapper::Header.build(attributes) }
    let(:options) { Hash[loader: :object_builder] }

    its(:model)  { should be(model) }
    its(:loader) { should be_instance_of(Mapper::LOADERS[:object_builder]) }
    its(:dumper) { should be_instance_of(Mapper::DEFAULT_DUMPER) }
    its(:header) { should be(header) }
  end

  describe 'loader is set to :attribute_writer' do
    let(:header)  { Mapper::Header.build(attributes) }
    let(:options) { Hash[loader: :attribute_writer] }

    its(:model)  { should be(model) }
    its(:loader) { should be_instance_of(Mapper::LOADERS[:attribute_writer]) }
    its(:dumper) { should be_instance_of(Mapper::DEFAULT_DUMPER) }
    its(:header) { should be(header) }
  end
end
