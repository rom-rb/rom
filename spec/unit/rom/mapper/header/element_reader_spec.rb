# encoding: utf-8

require 'spec_helper'

describe Mapper::Header, '#[]' do
  subject { object[name] }

  let(:object)     { Mapper::Header.build(attributes) }
  let(:attributes) { [[:id, Integer]] }

  context 'when attribute exists' do
    let(:name) { :id }
    let(:id)   { Mapper::Attribute.coerce(attributes.first) }

    it { should eql(id) }
  end

  context 'when attribute does not exist' do
    let(:name) { :not_here }

    specify do
      expect { subject }.to raise_error(KeyError)
    end
  end
end
