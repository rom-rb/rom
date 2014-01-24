# encoding: utf-8

require 'spec_helper'

describe Session::Relation, '#track' do
  subject { users.track(user) }

  include_context 'Session::Relation'

  let(:user) { model.new(id: 3, name: 'John') }

  before do
    users.track(user)
  end

  it_behaves_like 'a command method'

  it { should be(subject) }

  it 'starts tracking the object' do
    expect(users.tracking?(user)).to be_true
  end
end
