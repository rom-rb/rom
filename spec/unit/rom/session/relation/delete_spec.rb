# encoding: utf-8

require 'spec_helper'

describe Session::Relation, '#delete' do
  subject { users.delete(user) }

  include_context 'Session::Relation'

  let(:state) { subject.state(user) }

  context 'with a persisted object' do
    it_behaves_like 'a command method'

    specify { expect(state).to be_deleted }
  end

  context 'with a transient object' do
    let(:user) { users.new }

    specify do
      expect { subject }.to raise_error(
        Session::State::TransitionError,
        'cannot delete object with ROM::Session::State::Transient state'
      )
    end
  end
end
