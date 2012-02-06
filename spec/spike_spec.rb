require 'spec_helper'

describe ::Session::Session do
  # This is a mock using the intermediate format interface 
  # of my mapper experiments http://github.com/mbj/mapper
  #
  class DummyMapper

    def dump_key(object)
      {
        :domain_objects => {
            :value_a => object.value_a
        }
      }
    end

    def load_key(object)
      values = object.fetch(:domain_objects)
      {
        :domain_objects => {
          :value_a => values.fetch(:value_a)
        }
      }
    end

    def dump(object)
      {
        :domain_objects => {
          :value_a => object.value_a,
          :value_b => object.value_b
        }
      }
    end

    def load(dump)
      values = dump.fetch(:domain_objects)

      DomainObject.new(
        values.fetch(:value_a),
        values.fetch(:value_b)
      )
    end
  end

  class DummyAdapter
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

    def read(query)
      query.call
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
  #let(:alt_adapter) { DummyAdapter.new }

  let(:a) { DomainObject.new(:a,"some value a") }
  let(:b) { DomainObject.new(:b,"some value b") }
  let(:c) { DomainObject.new(:c,"some value c") }

  let(:session) do 
    ::Session::Session.new(
      :mapper => mapper,
      :adapter => adapter
    )
  end

  context 'when queriing objects' do

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

      context 'when many objects where read' do
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
              adapter.updates.should == [mapper.dump(a)]
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
            mapper.dump(a),
            mapper.dump(b)
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
