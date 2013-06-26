require 'spec_helper'

describe Session, '.start' do
  include_context 'Session::Relation'

  it 'starts a new session' do
    Session.start(:users => relation) do |session|
      expect(session).to be_clean
      expect(session).to be_instance_of(Session)
      expect(session[:users]).to be_instance_of(Session::Relation)
    end
  end
end
