require 'spec_helper'

describe Mapper, '#dump' do
  subject(:mapper) { described_class.new(loader, dumper) }

  let(:loader) { fake(:loader) { Mapper::Loader } }
  let(:dumper) { fake(:dumper) { Mapper::Dumper } }
  let(:data)   { [1, 'Jane'] }
  let(:object) { model.new(id: 1, name: 'Jane') }
  let(:model)  { mock_model(:id, :name) }

  it 'dumps the object into data tuple' do
    stub(dumper).call(object) { data }

    expect(mapper.dump(object)).to be(data)

    dumper.should have_received.call(object)
  end
end
