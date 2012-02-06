require 'spec_helper'
# This is a WIP and still unstructured. But I plan to use it in one of my apps. 

describe ::Session::Session do
  # This is a mock using the intermediate format interface 
  # of my mapper experiments http://github.com/mbj/mapper
  # Currently not compatible since expanded for keys!
  #
  # keys:
  #
  #   A key is any hash that identifies the database record/document/row
  #   where the operation should be performed. The key is created by mapping.
  #
  class DummyMapper

    # Dumps an object into intermediate representation.
    # Two level hash, first level is collection, second the 
    # values for the entry.
    # So you can map to multiple collection entries.
    # Currently im only specing AR pattern in this test, 
    # but time will change!
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

    def remove(dump)
      @removes << dump
    end

    # TODO: 4 params? Am I dump?
    # @param [Symbol] the collectio where the update should happen
    # @param [Hash] update_key the key to update the record under
    # @param [Hash] new_record the updated record (all fields!)
    # @param [Hash] old_record the old record (all fields!)
    #
    def update(collection,update_key,new_record,old_record)
      @updates << [collection,update_key,new_record,old_record]
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

  let(:object)       { DomainObject.new(:key_value,"some value") }
  let(:other_object) { DomainObject.new(:other_key,"other value") }

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
        mapper.dump(subject.first).should == mapper.dump(object)
      end
    end

    context 'when object was NOT loaded before' do

      let(:objects) { [object,other_object] }

      context 'when one object is read' do
        let(:finder) { lambda { [mapper.dump(object)] } }
     
        it_should_behave_like 'a one object read'
      end

      context 'when many objects are read' do
        let(:finder) { lambda { objects.map { |o| mapper.dump(o) } } }

        it 'should return array of objects' do
          subject.length.should == objects.length
        end

        it 'should return objects' do
          subject.map { |o| mapper.dump(o) }.should == objects.map { |o| mapper.dump(o) }
        end
      end
    end

    context 'when object was loaded before' do
      before do
        session.insert(object)
        session.commit
      end

      context 'when loaded object is read' do
        let(:finder) { lambda { [mapper.dump(object)] } }

        it_should_behave_like 'a one object read'

        it 'should return the loaded object' do
          subject.first.should == object
        end
      end
    end
  end

  context 'when removing records' do
    before do
      session.insert(object)
      session.commit
    end

    shared_examples 'a successful remove' do
      before do
        session.remove(object)
        session.commit
      end

      it 'should remove via adapter' do
        adapter.removes.should == [mapper.dump(object)]
      end

      it 'should unload the object' do
        session.loaded?(object).should be_false
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
        session.remove(object)
        session.remove?(object).should be_true
      end

      it_should_behave_like 'a successful remove'
    end

    context 'when record is loaded dirty and NOT staged for update' do
      it 'should raise on commit' do
        expect do
          object.key_attribute = :c
          session.remove(object)
          session.commit
        end.to raise_error(RuntimeError,'cannot remove dirty object')
      end
    end

    context 'when record is loaded and staged for update' do
      before do
        session.update(object)
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
          session.update(object)
        end.to raise_error
      end
    end

    shared_examples_for 'a successful update commit' do
      before do
        session.commit
      end

      it 'should unregister update' do
        session.update?(object).should be_false
      end
    end

    shared_examples_for 'a successful update registration' do
      it 'should register an update' do
        session.update?(object).should be_true
      end
    end

    context 'when object was loaded' do
      let!(:object) { DomainObject.new(:a,"some value") }
      before do
        session.insert(object)
        session.commit
      end

      context 'and object was not dirty' do
        before do
          session.update(object)
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
        let!(:dump_before) { mapper.dump(object) }

        before do
          object.other_attribute = :b
          session.update(object)
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
              adapter.updates.should == [mapper.dump(object)]
            end

            it 'should tack the object as NON dirty' do
              session.dirty?(object).should be_false
            end
          end
        end
      end
    end
  end

  context 'when inserting' do
    context 'when object is new' do
      before do
        session.insert(object)
      end
     
      it 'should mark the records as insert' do
        session.insert?(object).should be_true
        session.insert?(other_object).should be_false
      end
     
      it 'should not allow to update the records' do
        expect do
          session.update(object)
        end.to raise_error
      end
     
      context 'when commiting' do
        before do
          session.commit
        end
     
        it 'should send dumped objects to adapter' do
          adapter.inserts.should == [
            mapper.dump(object)
          ]
        end
       
        it 'should unmark the records as inserts' do
          session.insert?(object).should be_false
        end
     
        it 'should mark the records as loaded' do
          session.loaded?(object).should be_true
          session.loaded?(other_object).should be_false
        end
      end
    end
  end
end
