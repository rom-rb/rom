require 'spec_helper'

describe Session::Relation, '#state' do
  subject { users.state(user) }

  include_context 'Session::Relation'

  context 'when object is tracked' do
    it { should be_kind_of(Session::State) }

    its(:object) { should be(user) }
  end

  context 'when object is not tracked' do
    let(:user) { model.new }

    specify do
      expect { subject }.to raise_error(
        Session::Tracker::ObjectNotTrackedError,
        "Tracker doesn't include #{user.inspect}"
      )
    end
  end
end
