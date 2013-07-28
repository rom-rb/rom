require 'spec_helper'

describe Session::Relation, '#dirty?' do
  subject { users.dirty?(user) }

  include_context 'Session::Relation'

  context 'with a transient object' do
    let(:user) { users.new }

    it { should be(true) }
  end

  context 'when persisted object was changed' do
    before do
      user.name = 'John Doe'
    end

    it { should be(true) }
  end

  context 'when persisted object was not changed' do
    it { should be(false) }
  end

  context 'when object is not tracked' do
    let(:user) { model.new(:id => 3, :name => 'Unknown') }

    specify do
      expect { subject }.to raise_error(
        Session::Tracker::ObjectNotTrackedError,
        "Tracker doesn't include #{user.inspect}"
      )
    end
  end
end
