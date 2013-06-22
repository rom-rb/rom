require 'spec_helper'

describe Session do
  subject(:session) { described_class.new(registry) }

  let(:registry) { Session::Registry.new({ :users => relation }, tracker) }
  let(:tracker)  { Session::Tracker.new }

  let(:mapper)   { Mapper.build(Mapper::Header.coerce([[:id, Integer], [:name, String]], :keys => [:id]), model) }
  let(:model)    { mock_model(:id, :name) }
  let(:users)    { Axiom::Relation.new(SCHEMA[:users].header, [ [ 1, 'John' ], [ 2, 'Jane' ] ]) }
  let(:relation) { Relation.new(users, mapper) }

  let(:object) { registry[:users].all.first }

  describe '#dirty?' do
    context 'when persisted object was changed' do
      it 'returns true' do
        object.name = 'John Doe'
        expect(session[:users].dirty?(object)).to be_true
      end
    end

    context 'when persisted object was not changed' do
      it 'returns false' do
        expect(session[:users].dirty?(object)).to be_false
      end
    end
  end

  describe '#track' do
    it 'starts tracking an object' do
      user = model.new(:id => 3, :name => 'John')

      session[:users].track(user)

      expect(session[:users].tracking?(user)).to be_true
    end
  end

  describe '#save' do
    context 'when an object is persisted' do
      it 'queues an object to be updated' do
        session[:users].save(object)

        expect(session[:users].state(object)).to be_updated
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
