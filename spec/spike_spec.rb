require 'spec_helper'

describe ::Session::Session do
  class Mapper
    def initialize
      @mapping = {
      }
    end

    def dump(object)
      { :default => object.value }
    end

    def load(object)
      DomainObject.new(object.fetch(:default))
    end
  end

  class Adapter
    attr_reader :inserts,:removes,:updates

    def initialize
      @removes,@inserts,@updates = [],[],[]
    end

    def insert(object)
      @inserts << object
    end

    def remove(object)
      @removes << object
    end

    def update(object)
      @updates << object
    end
  end

  class DomainObject
    attr_accessor :value
    def initialize(value=0)
      @value=value
    end
  end

  let(:mapper) { Mapper.new }
  let(:adapter) { Adapter.new }
  let(:alt_adapter) { Adapter.new }

  let(:a) { DomainObject.new(:a) }
  let(:b) { DomainObject.new(:b) }
  let(:c) { DomainObject.new(:c) }

  let(:session) do 
    ::Session::Session.new(
      :mapper => mapper,
      :adapters => { 
        :default => adapter ,
        :alt => alt_adapter
      }
    )
  end

  context 'when removing records' do
    before do
      session.insert(a)
      session.commit
    end

    shared_examples 'a successful remove' do
      before do
        session.remove(a)
        session.commit
      end

      it 'should remove via adapter' do
        adapter.removes.should == [:a]
      end

      it 'should unload the object' do
        session.loaded?(a).should be_false
      end
    end

    context 'when object is not loaded' do
      it 'should raise' do
        expect do
          session.remove(b)
        end.to raise_error
      end
    end

    context 'when object is loaded and not dirty' do
      it 'should mark the object to be removed' do
        session.remove(a)
        session.remove?(a).should be_true
      end

      it_should_behave_like 'a successful remove'
    end

    context 'when record is loaded dirty and NOT staged for update' do
      it 'should raise on commit' do
        expect do
          a.value = :c
          session.remove(a)
          session.commit
        end.to raise_error(RuntimeError,'cannot remove dirty object')
      end
    end

    context 'when record is loaded and staged for update' do
      before do
        session.update(a)
      end

      it 'should raise' do
        expect do
          session.remove(b)
        end.to raise_error
      end
    end
  end

  context 'when updateing objects' do
    context 'when object was not loaded' do 
      it 'should raise' do
        expect do
          session.update(a)
        end.to raise_error
      end
    end

    shared_examples_for 'a successful update commit' do
      before do
        session.commit
      end

      it 'should unregister update' do
        session.update?(a).should be_false
      end
    end

    shared_examples_for 'a successful update registration' do
      it 'should register an update' do
        session.update?(a).should be_true
      end
    end

    context 'when object was loaded' do
      before do
        session.insert(a)
        session.commit
      end

      context 'and object was not dirty' do
        before do
          session.update(a)
        end

        it_should_behave_like 'a successful update registration'

        context 'on commit' do
          it_should_behave_like 'a successful update commit' do
            it 'should NOT update via the adapter' do
              adapter.updates.should == []
            end
          end
        end
      end

      context 'and object was dirty' do
        before do
          a.value = :b
          session.update(a)
        end

        it_should_behave_like 'a successful update registration'

        context 'on commit' do
          it_should_behave_like 'a successful update commit' do
            it 'should update via the adapter' do
              adapter.updates.should == [:b]
            end

            it 'should mark the object as not dirty' do
              session.dirty?(a).should be_false
            end
          end
        end
      end
    end
  end

  context 'when inserting new records' do
    before do
      session.insert(a)
      session.insert(b)
    end

    it 'should mark the records as new' do
      session.new?(a).should be_true
      session.new?(b).should be_true
      session.new?(c).should be_false
    end

    it 'should not allow to update the records' do
      expect do
        session.update(a)
      end.to raise_error
    end

    context 'when commiting' do
      before do
        session.commit
      end

      it 'should send dumped objects to adapter' do
        adapter.inserts.should == [:a,:b]
      end
     
      it 'should unmark the records as new' do
        session.new?(a).should be_false
        session.new?(b).should be_false
        session.new?(c).should be_false
      end

      it 'should mark the records as loaded' do
        session.loaded?(a).should be_true
        session.loaded?(b).should be_true
        session.loaded?(c).should be_false
      end
    end
  end
end
