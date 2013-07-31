require 'spec_helper'

describe Session, '#flush' do
  subject { session.flush }

  include_context 'Session::Relation'

  let(:object) { session }

  let(:john)  { session[:users].to_a.first }
  let(:jane)  { session[:users].to_a.last }
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
    expect(subject[:users].to_a).to_not include(john)
  end

  it 'commits all updates' do
    expect(subject[:users].to_a.first).to eq(relation.to_a.first)
  end

  it 'commits all inserts' do
    expect(subject[:users].to_a).to include(piotr)
  end

  it 'sets correct state for created objects' do
    expect(subject[:users].state(piotr)).to be_persisted
    expect(subject[:users].dirty?(piotr)).to be(false)
  end

  it 'registers newly created object in the IM' do
    expect(subject[:users].restrict { |r| r.name.eq('Piotr') }.to_a.first).to be(piotr)
  end

  it 'sets correct state for updated objects' do
    expect(subject[:users].state(jane)).to be_persisted
  end

  it 'sets correct state for deleted objects' do
    expect(subject[:users].state(john)).to be_frozen
  end

end
