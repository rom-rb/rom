require 'spec_helper'

describe ::Session::Session do
  class DummyMapper
    def dump(object)
      { :default => dump_value(object) }
    end

    def dump_value(object)
      {
        :domain_objects => {
          :values => { 
             :value_a => object.value_a,
             :value_b => object.value_b
          }, 
          :keys => [:value_a] 
        }
      }
    end

    def load(object)
      repo = object.fetch(:default)
      collection = repo.fetch(:domain_objects)
      values = collection.fetch(:values)
      DomainObject.new(
        values.fetch(:value_a),
        values.fetch(:value_b)
      )
    end
  end

  class DummyAdapter
    attr_reader :inserts,:removes,:updates,:data

    def initialize
      @data,@removes,@inserts,@updates = [],[],[],[]
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

    def read(query)
      query.call(@data)
    end
  end

  class DomainObject
    attr_accessor :value_a,:value_b
    def initialize(value_a,value_b)
      @value_a,@value_b = value_a,value_b
    end
  end

  let(:mapper) { DummyMapper.new }
  let(:adapter) { DummyAdapter.new }
  let(:alt_adapter) { DummyAdapter.new }

  let(:a) { DomainObject.new(:a,"some value a") }
  let(:b) { DomainObject.new(:b,"some value b") }
  let(:c) { DomainObject.new(:c,"some value c") }

  let(:session) do 
    ::Session::Session.new(
      :mapper => mapper,
      :adapters => { 
        :default => adapter ,
        :alt => alt_adapter
      }
    )
  end

  context 'when loading objects' do
    before do
      adapter.data << mapper.dump_value(a)
      adapter.data << mapper.dump_value(b)
      adapter.data << mapper.dump_value(c)
    end

    context 'when object could not be found' do
      let(:finder) { lambda { |data| nil } }

      subject { session.load(finder) }

      it 'should return empty array' do
        should == []
      end
    end

    context 'when object was NOT loaded before' do
      context 'when one object was read' do
        let(:finder) { lambda { |data| data.first } }
     
        subject { session.load(finder) }
     
        it 'should return array of length 1' do
          subject.length.should == 1
        end
     
        it 'should return object' do
          mapper.dump(subject.first).should == mapper.dump(a)
        end
      end

      context 'when many objects where read' do
        let(:finder) { lambda { |data| data } }

        subject { session.load(finder) }

        it 'should return array of objects' do
          subject.length.should == 3
        end

        it 'should return objects' do
          mapper.dump(subject[0]).should == mapper.dump(a)
          mapper.dump(subject[1]).should == mapper.dump(b)
          mapper.dump(subject[2]).should == mapper.dump(c)
        end
      end
    end
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
        adapter.removes.should == [mapper.dump_value(a)]
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
          a.value_a = :c
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
          a.value_a = :b
          session.update(a)
        end

        it_should_behave_like 'a successful update registration'

        context 'on commit' do
          it_should_behave_like 'a successful update commit' do
            it 'should update via the adapter' do
              adapter.updates.should == [mapper.dump_value(a)]
            end

            it 'should mark the object as not dirty' do
              session.dirty?(a).should be_false
            end
          end
        end
      end
    end
  end

  context 'when inserting' do
    context 'when object is new' do
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
          adapter.inserts.should == [
            mapper.dump_value(a),
            mapper.dump_value(b)
          ]
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
end
