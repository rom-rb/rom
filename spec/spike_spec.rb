require 'spec_helper'

describe ::Session::Session do
  # This is a mock using the intermediate format interface 
  # of my mapper experiments http://github.com/mbj/mapper
  # Currently not compatible since expanded for keys!
  #
  class DummyMapper

    # Dumps an object into intermediate representation.
    # Two level hash, first level is collection, second the 
    # values for the entry.
    # So you can map to multiple collection entries.
    # Currently im only specing AR pattern, but time will change!
    #
    def dump(object)
      {
        :domain_objects => {
          :key_attribute => object.key_attribute,
          :other_attribute => object.other_attribute
        }
      }
    end

    # Loads an object from intermediate represenation.
    # Same format as dump but operation is reversed.
    # Construction of objects can be don in a ORM-Model component
    # specific subclass (Virtus?)
    #
    def load(dump)
      values = dump.fetch(:domain_objects)

      DomainObject.new(
        values.fetch(:key_attribute),
        values.fetch(:other_attribute)
      )
    end

    # Dumps a key intermediate representation from object
    def dump_key(object)
      {
        :domain_objects => {
          :key_attribute => object.key_attribute
        }
      }
    end

    # Loads a key intermediate representation from dump
    def load_key(dump)
      values = dump.fetch(:domain_objects)
      {
        :domain_objects => {
          :key_attribute => values.fetch(:key_attribute)
        }
      }
    end
  end

  # Dummy adapter that records interactions. 
  class DummyAdapter
    attr_reader :inserts,:removes,:updates

    def initialize
      @removes,@inserts,@updates = [],[],[]
    end

    def insert(object)
      @inserts << object
    end

    def remove(dump_key)
      @removes << dump_key
    end

    # This is the most complex. 
    # I basically whant adapter to get all information without 
    # any dependencies to the session. hash of hashes for speciying 
    # key should be sufficent. This interface is fluid and will be speced more 
    #
    # FIXME: Needs to change since per mapped collection keys are needed!
    def update(key_dump,new_dump,old_dump)
      @updates << [key_dump,new_dump,old_dump]
    end

    # Returns arrays of intermediate representations of matched models.
    # Adapters do not have to deal with creating model instances etc.
    def read(query)
      query.call
    end
  end

  # The keylike behaviour of :key_attribute is defined by mapping. 
  # The key_ prefix is only cosmetic here!
  # Simple PORO, but could also be a virtus model, but I'd like to 
  # make sure I do not couple to its API.
  class DomainObject
    attr_accessor :key_attribute,:other_attribute
    def initialize(key_attribute,other_attribute)
      @key_attribute,@other_attribute = key_attribute,other_attribute
    end
  end

  let(:mapper) { DummyMapper.new }
  let(:adapter) { DummyAdapter.new }

  let(:a) { DomainObject.new(:a,"some value a") }
  let(:b) { DomainObject.new(:b,"some value b") }
  let(:c) { DomainObject.new(:c,"some value c") }

  let(:session) do 
    ::Session::Session.new(
      :mapper => mapper,
      :adapter => adapter
    )
  end

  context 'when quering objects' do

    subject { session.query(finder) }

    context 'when object could not be found' do
      let(:finder) { lambda { [] } }

      subject { session.query(finder) }

      it 'should return empty array' do
        should == []
      end
    end

    shared_examples_for 'a one object read' do
      it 'should return array of length 1' do
        subject.length.should == 1
      end
     
      it 'should return object' do
        mapper.dump(subject.first).should == mapper.dump(a)
      end
    end

    context 'when object was NOT loaded before' do

      context 'when one object is read' do
        let(:finder) { lambda { [mapper.dump(a)] } }
     
        it_should_behave_like 'a one object read'
      end

      context 'when many objects are read' do
        let(:finder) { lambda { [a,b,c].map { |o| mapper.dump(o) } } }

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

    context 'when object was loaded before' do
      before do
        session.insert(a)
        session.commit
      end

      context 'when loaded object is read' do
        let(:finder) { lambda { [mapper.dump(a)] } }

        it_should_behave_like 'a one object read'

        it 'should return the loaded object' do
          subject.first.should == a
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
        adapter.removes.should == [mapper.dump(a)]
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
          a.key_attribute = :c
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
        let!(:object) { DomainObject.new(:a,"some value") }
        let!(:dump_before) { mapper.dump(object) }

        before do
          object.other_attribute = :b
          session.update(a)
        end

        it_should_behave_like 'a successful update registration'

        shared_examples_for 'an update on adapter' do
          let(:update)   { adapter.updates.first }
          let(:key)      { update[0] }
          let(:new_dump) { update[1] }
          let(:old_dump) { update[2] }

          it 'should use the correct key' do
            key.should == mapper.load_key(dump_before)
          end

          it 'should use the correct old dump' do
            old_dump.should == dump_before
          end

          it 'should use the correct new dump' do
            new_dump.should == new_dump
          end
        end

        context 'on commit' do
          it_should_behave_like 'a successful update commit' do


            it 'should update via the adapter' do
              adapter.updates.should == [mapper.dump(a)]
            end

            it 'should tack the object as NON dirty' do
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
     
      it 'should mark the records as insert' do
        session.insert?(a).should be_true
        session.insert?(b).should be_true
        session.insert?(c).should be_false
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
            mapper.dump(a),
            mapper.dump(b)
          ]
        end
       
        it 'should unmark the records as new' do
          session.insert?(a).should be_false
          session.insert?(b).should be_false
          session.insert?(c).should be_false
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
