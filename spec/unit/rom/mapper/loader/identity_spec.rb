require 'spec_helper'

describe ROM::Mapper::Loader, '#call' do
  include_context 'Mapper::Loader'

  it 'returns object identity' do
    expect(loader.identity(tuple)).to eql([1])
  end
end
