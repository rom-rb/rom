# encoding: utf-8

require 'spec_helper'

describe Session::Mapper, '#load' do
  subject { object.load(tuple) }

  let(:object) { described_class.new(mapper, tracker, im) }

  let(:mapper) { fake(:mapper) { ROM::Mapper } }

  let(:tuple)   { Hash[id: 1, name: 'Jane'] }
  let(:user)    { model.new(tuple) }
  let(:model)   { mock_model(:id, :name) }
  let(:im)      { Session::IdentityMap.build }
  let(:tracker) { Session::Tracker.new }

  before do
    stub(mapper).identity_from_tuple(tuple) { 1 }
  end

  context 'when IM does not include the loaded object' do
    it 'loads the object' do
      stub(mapper).load(tuple) { user }
      expect(subject).to be(user)
      mapper.should have_received.load(tuple)
    end

    it 'stores persisted state in the tracker' do
      expect(tracker.fetch(subject)).to be_persisted
    end
  end

  context 'when IM includes the loaded object' do
    before do
      im.store(1, user, tuple)
    end

    it 'returns already loaded object' do
      expect(subject).to be(user)
      mapper.should_not have_received.load(tuple)
    end
  end
end
