# encoding: utf-8

require 'spec_helper'

describe Mapper, '#call' do
  subject { object.call(relation) }

  let(:object) {
    Mapper.build(header, model: model)
  }

  let(:header) {
    Mapper::Header.build([
      [:id,   type: Integer, from: :id],
      [:name, type: String,  from: :user_name],
      [:age,  type: Integer]
    ])
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
