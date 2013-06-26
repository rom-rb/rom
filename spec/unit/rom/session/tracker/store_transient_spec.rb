require 'spec_helper'

describe Session::Tracker, '#store_transient' do
  subject { object.store_transient(user) }

  let(:user)   { Object.new }
  let(:object) { described_class.new }

  it_behaves_like 'a command method'

  it 'stores transient object' do
    expect(subject.fetch(user)).to be_transient
  end
end
