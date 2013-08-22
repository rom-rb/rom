# encoding: utf-8

require 'spec_helper'

describe Session, '.start' do
  include_context 'Session::Relation'

  let(:user) { model.new(:id => 3, :name => 'Piotr') }

  it 'starts a new session' do
    Session.start(:users => relation) do |session|
      expect(session).to be_clean
      expect(session).to be_instance_of(Session)
      expect(session[:users]).to be_instance_of(Session::Relation)

      session[:users].track(user).save(user)

      session.flush
    end

    expect(relation.to_a).to include(user)
  end
end
