require 'spec_helper'

describe Mapper, '#call' do
  subject { object.call(relation) }

  let(:object) {
    Mapper.new(header, loader, dumper)
  }

  let(:header) {
    Mapper::Header.coerce(relation.header, map: { user_id: :id, user_name: :name })
  }

  let(:relation) {
    Axiom::Relation::Base.new(:users, [[:user_id, Integer], [:user_name, String]])
  }

  fake(:loader) { Mapper::Loader }
  fake(:dumper) { Mapper::Dumper }

  it 'renames relation' do
    expect(subject.header.map(&:name)).to eq([:id, :name])
  end
end
