require 'spec_helper'

describe Session::Relation, '#dirty?' do
  subject { users.dirty?(user) }

  include_context 'Session::Relation'

  context 'when persisted object was changed' do
    before do
      user.name = 'John Doe'
    end

    it { should be(true) }
  end

  context 'when persisted object was not changed' do
    it { should be(false) }
  end

  context 'when object is not in the IM' do
    let(:user) { model.new(:id => 3, :name => 'Unknown') }

    specify do
      expect { subject }.to raise_error(
        Session::IdentityMap::ObjectMissingError,
        'An object with identity=[3] was not found in the identity map'
      )
    end
  end
end
