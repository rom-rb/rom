require 'spec_helper'

describe Session::Mapper, '#load' do
  subject(:mapper) { described_class.new(loader, dumper, im) }

  let(:loader) { fake(:loader) { ROM::Mapper::Loader } }
  let(:dumper) { fake(:dumper) { ROM::Mapper::Dumper } }
  let(:tuple)  { Hash[:id => 1, :name => 'Jane'] }
  let(:object) { model.new(tuple) }
  let(:model)  { mock_model(:id, :name) }

  context 'when IM includes the loaded object' do
    let(:im) { Session::IdentityMap.new }

    before do
      im.store(1, object, tuple)
    end

    it 'returns the already loaded object' do
      stub(loader).identity(tuple) { 1 }

      expect(mapper.load(tuple)).to be(object)

      loader.should_not have_received.call(tuple)
    end
  end

  context 'when IM does not include the loaded object' do
    let(:im) { Session::IdentityMap.new }

    it 'returns a newly loaded object' do
      stub(loader).identity(tuple) { 1 }
      stub(loader).call(tuple) { object }

      expect(mapper.load(tuple)).to be(object)

      loader.should have_received.call(tuple)
    end
  end
end
