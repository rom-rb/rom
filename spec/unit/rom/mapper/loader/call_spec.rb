require 'spec_helper'

describe ROM::Mapper::Loader, '#call' do
  include_context 'Mapper::Loader'

  it 'returns loaded object' do
    stub(transformer).call(tuple) { object }
    expect(loader.call(tuple)).to eql(object)
  end
end
