require 'spec_helper'

describe Session::Relation, '#save' do
  subject { object.save(user) }

  include_context 'Session::Relation'

  let(:state) { subject.state(user) }

  context 'when an object is transient' do
    let(:user) { users.new(:id => 3, :name => 'John') }

    it_behaves_like 'a command method'

    specify { state.should be_created }
  end

  context 'when an object is persisted' do
    context 'when not dirty' do
      it_behaves_like 'a command method'

      specify { state.should be_persisted }
    end

    context 'when dirty' do
      before do
        user.name = 'John Doe'
      end

      it_behaves_like 'a command method'

      specify { state.should be_updated }
    end
  end
end
