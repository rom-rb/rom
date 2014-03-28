# encoding: utf-8

require 'spec_helper'

describe Mapper::Header, '#to_ast' do
  subject(:header) { Mapper::Header.build([[:id], [:name]]) }

  it 'returns a morpher transformer node that can load an attribute hash' do
    expect(Morpher.compile(header.to_ast).call(id: 1, name: 'Jane', other: 'Foo')).to eql(id: 1, name: 'Jane')
  end
end
