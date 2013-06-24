require 'spec_helper'

describe Session do
  subject(:session) { described_class.new(env) }

  let(:env)      { Session::Environment.new({ :users => relation }, tracker) }
  let(:tracker)  { Session::Tracker.new }

  let(:mapper)   { Mapper.build(Mapper::Header.coerce([[:id, Integer], [:name, String]], :keys => [:id]), model) }
  let(:model)    { mock_model(:id, :name) }
  let(:users)    { Axiom::Relation.new(SCHEMA[:users].header, [ [ 1, 'John' ], [ 2, 'Jane' ] ]) }
  let(:relation) { Relation.new(users, mapper) }

  let(:object) { env[:users].all.first }

  describe '#delete' do
    it 'queues an object to be deleted' do
      session[:users].delete(object)

      expect(session[:users].state(object)).to be_deleted
    end
  end
end
