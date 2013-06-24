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

  describe '#track' do
    it 'starts tracking an object' do
      user = model.new(:id => 3, :name => 'John')

      session[:users].track(user)

      expect(session[:users].tracking?(user)).to be_true
    end
  end

  describe '#save' do
    context 'when an object is persisted' do
      context 'when not dirty' do
        it 'does not queue an object to be updated' do
          session[:users].save(object)

          expect(session[:users].state(object)).to be_persisted
        end
      end

      context 'when dirty' do
        it 'queues an object to be updated' do
          object.name = 'John Doe'

          session[:users].save(object)

          expect(session[:users].state(object)).to be_updated
        end
      end
    end

    context 'when an object is new' do
      it 'queues an object to be created' do
        user = model.new(:id => 3, :name => 'John')

        session[:users].track(user)
        session[:users].save(user)

        expect(session[:users].state(user)).to be_created
      end
    end
  end

  describe '#delete' do
    it 'queues an object to be deleted' do
      session[:users].delete(object)

      expect(session[:users].state(object)).to be_deleted
    end
  end
end
