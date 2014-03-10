# encoding: utf-8

require 'spec_helper'

describe Mapper::Dumper, '#call' do
  subject(:dumper) { described_class.build(header, transformer) }

  let(:transformer) { mock('transformer') }

  let(:header) { Mapper::Header.build([[:uid, Integer], [:name, String]], map: { uid: :id }, keys: [:uid]) }
  let(:data)   { Hash[id: 1, name: 'Jane'] }
  let(:model)  { mock_model(:id, :name) }
  let(:object) { model.new(data) }

  before do
    pending
  end

  context 'with public attribute readers' do
    it 'returns dumped tuple' do
      expect(dumper.call(object)).to eq([1, 'Jane'])
    end
  end

  context 'with private attribute readers' do
    before do
      model.send(:private, :id)
      model.send(:private, :name)
    end

    it 'returns dumped tuple' do
      expect(dumper.call(object)).to eq([1, 'Jane'])
    end
  end
end
