# encoding: utf-8

require 'spec_helper'

describe Mapper::Header, '#project' do
  subject(:header) { other.project([:id]) }

  let(:other) { Mapper::Header.build([[:id], [:name]]) }

  it 'returns a header with projected attributes' do
    expect(header).to eql(Mapper::Header.build([[:id]]))
  end
end
