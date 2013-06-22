require 'spec_helper'

describe 'Session' do
  let(:mapper) { Mapper.build(Mapper::Header.coerce([[:id, Integer], [:name, String]], :keys => [:id]), model) }
  let(:model)  { mock_model(:id, :name) }

  # we're using an in-memory relation
  let(:users)    { Axiom::Relation.new(SCHEMA[:users].header, [ [ 1, 'John' ], [ 2, 'Jane' ] ]) }
  let(:relation) { Relation.new(users, mapper) }

  specify 'fetching an object from a relation' do
    Session.start(:users => relation) do |env|
      # fetch user for the first time
      jane1 = env[:users].restrict { |r| r.name.eq('Jane') }.all.first

      expect(jane1).to eq(model.new(:id => 2, :name => 'Jane'))

      # here IM-powered loader kicks in
      jane2 = env[:users].restrict { |r| r.name.eq('Jane') }.all.first

      expect(jane1).to be(jane2)
    end
  end

  specify 'deleting an object from a relation' do
    Session.start(:users => relation) do |env|
      jane = env[:users].restrict { |r| r.name.eq('Jane') }.all.first

      users = env[:users].delete(jane).state(jane).commit.all

      expect(users).not_to include(jane)
    end
  end
end
