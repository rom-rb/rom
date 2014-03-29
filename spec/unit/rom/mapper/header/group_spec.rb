# encoding: utf-8

require 'spec_helper'

describe Mapper::Header, '#group' do
  subject(:header) { left.group(models: mapper) }

  let(:left) { Mapper::Header.build([[:id], [:name]]) }
  let(:mapper) { Mapper.build([[:id], [:title]]) }

  it 'returns a header with embedded collection attribute' do
    expected = Mapper::Header.build([
      [:id], [:name], mapper.attribute(Mapper::Attribute::EmbeddedCollection, :models)
    ])

    expect(header).to eq(expected)
  end
end
