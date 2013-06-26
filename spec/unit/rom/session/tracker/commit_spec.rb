require 'spec_helper'

describe Session::Tracker, '#commit' do
  subject { object.commit }

  let(:object) { described_class.new }

  fake(:user)      { Object }
  fake(:state)     { Session::State::Updated }
  fake(:new_state) { Session::State::Updated::Commited }

  it_behaves_like 'a command method'

  before do
    stub(state).object { user }
    stub(new_state).object { user }
    stub(state).commit { new_state }
    object.queue(state)
  end

  it 'commits states from changelog' do
    expect(subject).to be_clean
    state.should have_received.commit
  end
end
