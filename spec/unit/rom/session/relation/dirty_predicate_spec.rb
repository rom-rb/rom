require 'spec_helper'

describe Session::Relation, '#dirty?' do
  subject { users.dirty?(user) }

  include_context 'Session::Relation'

  let(:users) { session[:users] }

  context 'when persisted object was changed' do
    before do
      user.name = 'John Doe'
    end

    it { should be(true) }
  end

  context 'when persisted object was not changed' do
    it { should be(false) }
  end
end
