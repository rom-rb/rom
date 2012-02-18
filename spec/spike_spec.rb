require 'spec_helper'

describe ::Session::Session do
  let(:mapper)       { DummyMapper.new }
  let(:root_mapper)  { DummyMapperRoot.new(mapper) }

  let(:object)       { DomainObject.new(:key_value,"some value") }
  let(:other_object) { DomainObject.new(:other_key,"other value") }

  let(:session) do 
    ::Session::Session.new(root_mapper)
  end

  context 'when removing records' do
    before do
      session.insert(object)
      session.commit
    end

    shared_examples 'a delete' do
      before do
        session.delete(object)
        session.commit
      end

      it 'should delete via mapper' do
        mapper.deletes.should == [object]
      end

      it 'should unload the object' do
        session.track?(object).should be_false
      end
    end

    context 'when object is not tracked' do
      it 'should raise' do
        expect do
          session.delete(b)
        end.to raise_error
      end
    end

    context 'when object is tracked and not dirty' do
      it 'should mark the object to be deleted' do
        session.delete(object)
        session.delete?(object).should be_true
      end

      it_should_behave_like 'a delete'
    end

    context 'when record is tracked dirty and NOT staged for update' do
      it 'should raise on commit' do
        expect do
          object.key_attribute = :c
          session.delete(object)
          session.commit
        end.to raise_error(RuntimeError,'cannot delete dirty object')
      end
    end

    context 'when record is tracked and staged for update' do
      before do
        session.update(object)
      end

      it 'should raise' do
        expect do
          session.delete(object)
        end.to raise_error
      end
    end
  end

  context 'when updateing objects' do
    context 'when object was not tracked' do 
      it 'should raise' do
        expect do
          session.update(object)
        end.to raise_error
      end
    end

    shared_examples_for 'a update registration' do
      it 'should register an update' do
        session.update?(object).should be_true
      end
    end

    context 'when object was tracked' do
      let!(:object) { DomainObject.new(:a,"some value") }

      before do
        session.insert(object)
        session.commit
      end

      shared_examples_for 'a update commit' do
        before do
          session.commit
        end
     
        it 'should unregister update' do
          session.update?(object).should be_false
        end
      end

      context 'and object was not dirty' do
        before do
          session.update(object)
        end

        it_should_behave_like 'a update registration'

        context 'on commit' do
          it_should_behave_like 'a update commit' do
            it 'should NOT update via the mapper' do
              mapper.updates.should == []
            end
          end
        end
      end

      shared_examples_for 'an update on mapper' do
        before do
          session.commit
        end

        let(:update)     { mapper.updates.first }

        it 'should use the correct update' do
          mapper.updates.should == [[
            object,
            mapper.load_key(dump_before),
            dump_before
          ]]
        end
      end

      context 'and object was dirty' do
        let!(:dump_before) { mapper.dump(object) }

        context 'on non key' do
          before do
            object.other_attribute = :b
            session.update(object)
          end
         
          it_should_behave_like 'a update registration'
         
          context 'on commit' do
            it_should_behave_like 'a update commit'
            it_should_behave_like 'an update on mapper'
          end
        end

        context 'on key' do
          before do
            object.key_attribute = :b
            session.update(object)
          end
         
          it_should_behave_like 'a update registration'
         
          context 'on commit' do
            it_should_behave_like 'a update commit'
            it_should_behave_like 'an update on mapper'
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
     
        it 'should send objects to mapper' do
          mapper.inserts.should == [object]
        end
       
        it 'should unmark the records as inserts' do
          session.insert?(object).should be_false
        end
     
        it 'should mark the records as tracked' do
          session.track?(object).should be_true
          session.track?(other_object).should be_false
        end
      end
    end
  end
end
