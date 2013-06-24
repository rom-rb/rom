require 'spec_helper'

describe Session::Mapper, '#load' do
  subject { mapper.load(tuple) }

  let(:mapper) { described_class.new(loader, dumper, im) }
  let(:loader) { fake(:loader) { ROM::Mapper::Loader } }
  let(:dumper) { fake(:dumper) { ROM::Mapper::Dumper } }
  let(:tuple)  { Hash[:id => 1, :name => 'Jane'] }
  let(:object) { model.new(tuple) }
  let(:model)  { mock_model(:id, :name) }
  let(:im)     { Session::IdentityMap.new }

  before do
    stub(loader).identity(tuple) { 1 }
  end

  context 'when IM includes the loaded object' do
    before do
      im.store(1, object, tuple)
    end

    after do
      loader.should_not have_received.call(tuple)
    end

    it { should be(object) }
  end

  context 'when IM does not include the loaded object' do
    before do
      stub(loader).call(tuple) { object }
    end

    after do
      loader.should have_received.call(tuple)
    end

    it { should be(object) }
  end
end
