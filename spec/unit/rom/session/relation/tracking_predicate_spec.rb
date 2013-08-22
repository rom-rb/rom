# encoding: utf-8

require 'spec_helper'

describe Session::Relation, '#tracking?' do
  subject { users.tracking?(user) }

  include_context 'Session::Relation'

  let(:user) { model.new(:id => 3, :name => 'John') }

  context 'when the object is being tracked' do
    before do
      users.track(user)
    end

    it { should be(true) }
  end

  context 'when the object is not being tracked' do
    it { should be(false) }
  end
end
