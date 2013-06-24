require 'spec_helper'

describe Session::Relation, '#track' do
  subject { users.track(user) }

  include_context 'Session::Relation'

  let(:user) { model.new(:id => 3, :name => 'John') }

  before do
    users.track(user)
  end

  it { should be(subject) }

  it 'starts tracking the object' do
    expect(users.tracking?(user)).to be_true
  end
end
