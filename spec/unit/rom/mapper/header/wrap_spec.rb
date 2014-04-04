# encoding: utf-8

require 'spec_helper'

describe Mapper::Header, '#wrap' do
  subject(:header) { left.wrap(model: mapper) }

  let(:left) { Mapper::Header.build([[:id], [:name]]) }
  let(:mapper) { Mapper.build([[:id], [:title]]) }

  it 'returns a header with embedded value attribute' do
    expected = Mapper::Header.build([
      [:id], [:name], mapper.attribute(Mapper::Attribute::EmbeddedValue, :model)
    ])

    expect(header).to eq(expected)
  end
end
