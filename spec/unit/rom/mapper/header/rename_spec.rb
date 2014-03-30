# encoding: utf-8

require 'spec_helper'

describe Mapper::Header, '#rename' do
  subject(:header) { Mapper::Header.build([[:id], [:name]]) }

  it 'returns a new header with renamed attributes' do
    expect(header.rename(:id => :user_id)).to eql(Mapper::Header.build([[:user_id], [:name]]))
  end
end
