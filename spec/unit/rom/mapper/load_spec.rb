require 'spec_helper'

describe Mapper, '#load' do
  subject(:mapper) { described_class.new(loader, dumper) }

  let(:loader) { fake(:loader) { Mapper::Loader } }
  let(:dumper) { fake(:dumper) { Mapper::Dumper } }
  let(:data)   { [1, 'Jane'] }
  let(:tuple)  { Hash[uid: 1, name: 'Jane'] }
  let(:object) { model.new(id: 1, name: 'Jane') }
  let(:model)  { mock_model(:id, :name) }

  it 'loads the tuple into model' do
    stub(loader).call(tuple) { object }

    expect(mapper.load(tuple)).to be(object)

    loader.should have_received.call(tuple)
  end
end
