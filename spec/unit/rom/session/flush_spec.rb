require 'spec_helper'

describe Session, '#flush' do
  subject { session.flush }

  include_context 'Session::Relation'

  let(:object) { session }

  let(:john)  { session[:users].all.first }
  let(:jane)  { session[:users].all.last }
  let(:piotr) { session[:users].new(:id => 3, :name => 'Piotr') }

  before do
    session[:users].delete(john)

    jane.name = 'Jane Doe'
    session[:users].save(jane)

    session[:users].save(piotr)
  end

  it_behaves_like 'a command method'

  it { should be_clean }

  it 'commits all deletes' do
    expect(subject[:users].all).to_not include(john)
  end

  it 'commits all updates' do
    expect(subject[:users].all.first).to eq(relation.all.first)
  end

  it 'commits all inserts' do
    expect(subject[:users].all).to include(piotr)
  end

  it 'sets correct state for updated objects' do
    expect(subject[:users].state(jane)).to be_persisted
  end

end
