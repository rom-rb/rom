require 'spec_helper'

describe 'Session' do
  let(:mapper) { Mapper.build(Mapper::Header.coerce([[:id, Integer], [:name, String]], :keys => [:id]), model) }
  let(:model)  { mock_model(:id, :name) }

  specify 'fetching an object from a relation' do
    users = Axiom::Relation.new(
      SCHEMA[:users].header, [ [ 1, 'John' ], [ 2, 'Jane' ] ]
    )

    relation = Relation.new(users, mapper)

    session_registry = Session::Registry.new(Session::Tracker.new(:users => relation))

    # fetch user for the first time
    jane1 = session_registry[:users].restrict { |r| r.name.eq('Jane') }.all.first

    expect(jane1).to eq(model.new(:id => 2, :name => 'Jane'))

    # here IM-powered loader kicks in
    jane2 = session_registry[:users].restrict { |r| r.name.eq('Jane') }.all.first

    expect(jane1).to be(jane2)
  end
end
