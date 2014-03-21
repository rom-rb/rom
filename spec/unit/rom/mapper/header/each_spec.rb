# encoding: utf-8

require 'spec_helper'

describe Mapper::Header, '#each' do
  subject(:header) { Mapper::Header.build([[:id], [:name]]) }

  let(:id) { header[:id] }
  let(:name) { header[:name] }

  context 'with a block' do
    it 'yields attributes' do
      result = []

      header.each { |attribute| result << attribute }

      expect(result).to eql([id, name])
    end
  end

  context 'without a block' do
    subject { header.each }

    it { should be_instance_of(Enumerator) }
  end
end
