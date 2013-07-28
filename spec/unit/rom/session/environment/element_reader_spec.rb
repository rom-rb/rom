require 'spec_helper'

describe Session::Environment, '#[]' do
  subject { object[:users] }

  include_context 'Session::Environment'

  it 'returns session relation proxy' do
    expect(subject).to be_kind_of(Session::Relation)
  end
end
