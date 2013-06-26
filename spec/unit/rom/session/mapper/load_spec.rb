require 'spec_helper'

describe Session::Mapper, '#load' do
  subject { object.load(tuple) }

  let(:object) { described_class.new(mapper, tracker, im) }

  let(:mapper) { fake(:mapper) { ROM::Mapper } }
  let(:loader) { fake(:loader) { ROM::Mapper::Loader } }
  let(:dumper) { fake(:dumper) { ROM::Mapper::Dumper } }

  let(:tuple)   { Hash[:id => 1, :name => 'Jane'] }
  let(:user)    { model.new(tuple) }
  let(:model)   { mock_model(:id, :name) }
  let(:im)      { Session::IdentityMap.new }
  let(:tracker) { Session::Tracker.new }

  before do
    stub(mapper).loader { loader }
    stub(loader).identity(tuple) { 1 }
  end

  context 'when IM includes the loaded object' do
    before do
      im.store(1, user, tuple)
    end

    after do
      mapper.should_not have_received.load(tuple)
    end

    it { should be(user) }
  end

  context 'when IM does not include the loaded object' do
    before do
      stub(mapper).load(tuple) { user }
    end

    after do
      mapper.should have_received.load(tuple)
    end

    it { should be(user) }

    it 'stores persisted state in the tracker' do
      subject
      expect(tracker.fetch(user)).to be_persisted
    end
  end
end
