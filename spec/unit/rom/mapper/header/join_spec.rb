# encoding: utf-8

require 'spec_helper'

describe Mapper::Header, '#join' do
  subject(:header) { left.join(right) }

  let(:left) { Mapper::Header.build([[:id], [:name]]) }
  let(:right) { Mapper::Header.build([[:id], [:title]]) }

  it 'returns a joined header with uniq attributes' do
    expect(header).to eql(Mapper::Header.build([[:id], [:name], [:title]]))
  end
end
