require 'spec_helper'

describe Session::Tracker, '#store_persisted' do
  subject { object.store_persisted(user, mapper) }

  let(:object) { described_class.new }

  fake(:user) { Object }
  fake(:mapper)

  it_behaves_like 'a command method'

  it 'stores transient object' do
    expect(subject.fetch(user)).to be_persisted
  end
end
