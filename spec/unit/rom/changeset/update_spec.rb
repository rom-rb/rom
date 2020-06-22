# frozen_string_literal: true

RSpec.describe ROM::Changeset::Update do
  include_context 'changeset / database'
  include_context 'changeset / relations'

  subject(:changeset) do
    users.by_pk(jane[:id]).changeset(:update, data)
  end

  let(:data) do
    { name: 'Jane Doe' }
  end

  let!(:jane) do
    users.command(:create).call(name: 'Jane')
  end

  let!(:joe) do
    users.command(:create).call(name: 'Joe')
  end

  it 'has data' do
    expect(changeset.to_h).to eql(name: 'Jane Doe')
  end

  it 'has diff' do
    expect(changeset.diff).to eql(name: 'Jane Doe')
  end

  it 'has relation' do
    expect(changeset.relation.one).to eql(users.by_pk(jane[:id]).one)
  end

  it 'can be commited' do
    expect(changeset.commit.to_h).to eql(id: 1, name: 'Jane Doe')
    expect(users.by_pk(joe[:id]).one).to eql(joe)
  end
end
