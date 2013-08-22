# encoding: utf-8

require 'spec_helper'

describe Session, '#clean?' do
  subject { session.clean? }

  include_context 'Session::Relation'

  context 'when tracker has no pending state changes' do
    it { should be_true }
  end

  context 'when tracker has pending state changes' do
    before do
      session[:users].delete(user)
    end

    it { should be_false }
  end
end
