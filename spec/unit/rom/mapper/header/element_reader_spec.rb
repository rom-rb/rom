# encoding: utf-8

require 'spec_helper'

describe Mapper::Header, '#[]' do
  subject(:header) { Mapper::Header.build([[:id]]) }

  context 'when attribute exists' do
    subject { header[:id] }

    let(:id) { Mapper::Attribute.build(:id) }

    it { should eql(id) }
  end

  context 'when attribute does not exist' do
    specify do
      expect { header[:not_here] }.to raise_error(KeyError)
    end
  end
end
