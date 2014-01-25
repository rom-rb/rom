# encoding: utf-8

require 'spec_helper'

describe Session::Relation, '#update_attributes' do
  subject { object.update_attributes(user, new_attributes) }

  include_context 'Session::Relation'

  let(:state) { subject.state(user) }
  let(:new_attributes) { { name: 'Other' } }

  before do
    user.freeze
  end

  context 'when an object is persisted' do
    context 'when dirty' do
      it_behaves_like 'a command method'

      specify { state.should be_updated }
    end
  end

  context 'when an object is transient' do
    let(:user) { model.new }

    specify do
      expect { subject }.to raise_error(Session::ObjectNotTrackedError)
    end
  end

  context 'when an object is deleted' do
    before do
      object.delete(user)
    end

    specify do
      expect { subject }.to raise_error(
        Session::State::TransitionError,
        'cannot update object with ROM::Session::State::Deleted state'
      )
    end
  end
end
