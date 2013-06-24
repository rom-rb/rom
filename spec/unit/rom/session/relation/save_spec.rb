require 'spec_helper'

describe Session::Relation, '#save' do
  subject { users.save(user).state(user) }

  include_context 'Session::Relation'

  context 'when an object is new' do
    let(:user) { users.new(:id => 3, :name => 'John') }

    it { should be_created }
  end

  context 'when an object is persisted' do
    context 'when not dirty' do
      it { should be_persisted }
    end

    context 'when dirty' do
      before do
        user.name = 'John Doe'
      end

      it { should be_updated }
    end
  end
end
