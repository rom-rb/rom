# encoding: utf-8

shared_context 'Session::Relation' do
  let(:users)    { session[:users] }
  let(:object)   { users }

  let(:session)  { Session.new(env) }
  let(:env)      { Session::Environment.new({ :users => relation }, tracker) }
  let(:tracker)  { Session::Tracker.new }

  let(:mapper)   { Mapper.build([[:id, Integer], [:name, String]], model, :keys => [:id]) }
  let(:model)    { mock_model(:id, :name) }
  let(:header)   { TEST_ENV.schema[:users].header }
  let(:axiom)    { Axiom::Relation::Variable.new(Axiom::Relation.new(header, [[1, 'John'], [2, 'Jane']])) }
  let(:relation) { Relation.new(axiom, mapper) }

  let(:user) { session[:users].to_a.first }
end
