require 'spec_helper'

describe 'Session' do
  let(:mapper) { Mapper.build(Mapper::Header.coerce([[:id, Integer], [:name, String]], :keys => [:id]), model) }
  let(:model)  { mock_model(:id, :name) }

  # we're using an in-memory relation
  let(:users)    { Axiom::Relation.new(SCHEMA[:users].header, [ [ 1, 'John' ], [ 2, 'Jane' ] ]) }
  let(:relation) { Relation.new(users, mapper) }

  specify 'fetching an object from a relation' do
    Session.start(:users => relation) do |session|
      # fetch user for the first time
      jane1 = session[:users].restrict { |r| r.name.eq('Jane') }.all.first

      expect(jane1).to eq(model.new(:id => 2, :name => 'Jane'))

      # here IM-powered loader kicks in
      jane2 = session[:users].restrict { |r| r.name.eq('Jane') }.all.first

      expect(jane1).to be(jane2)
    end
  end

  specify 'deleting an object from a relation' do
    Session.start(:users => relation) do |session|
      jane = session[:users].restrict { |r| r.name.eq('Jane') }.all.first

      session[:users].delete(jane)

      session.flush

      expect(session[:users].state(jane).relation.all).not_to include(jane)
    end
  end

  specify 'saving an object to a relation' do
    Session.start(:users => relation) do |session|
      piotr = session[:users].new(:id => 3, :name => 'Piotr')

      session[:users].save(piotr)

      session.flush

      expect(session[:users].state(piotr).relation.all).to include(piotr)
    end
  end

  specify 'updating an object in a relation' do
    Session.start(:users => relation) do |session|
      jane = session[:users].restrict { |r| r.name.eq('Jane') }.all.first
      jane.name = 'Jane Doe'

      session[:users].save(jane)

      # FIXME: ROM::Relation#update doesn't work like expected
      #expect(users.size).to be(2)

      expect(session[:users].state(jane).relation.all.last).to be(jane)
    end
  end
end
