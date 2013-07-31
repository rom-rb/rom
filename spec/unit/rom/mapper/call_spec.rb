require 'spec_helper'

describe Mapper, '#call' do
  subject { object.call(relation) }

  let(:object) {
    Mapper.build(header, model)
  }

  let(:header) {
    Mapper::Header.build(
      [[:user_id, Integer], [:user_name, String], [:age, Integer]],
      map: { user_id: :id, user_name: :name }
    )
  }

  let(:model) {
    OpenStruct
  }

  let(:relation) {
    Axiom::Relation::Base.new(:users, [
      [:user_id, Integer], [:user_name, String], [:email, String], [:age, Integer]
    ])
  }

  it 'renames relation' do
    expect(subject.header.map(&:name)).to eq([:id, :name, :age])
  end
end
