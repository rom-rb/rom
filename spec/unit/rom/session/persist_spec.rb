require 'spec_helper'

describe ROM::Session, '#persist' do
  subject { object.persist(domain_object) }

  let(:mapper)        { registry.resolve_model(Spec::DomainObject)     }
  let(:registry)      { Spec::Registry.new                             }
  let(:domain_object) { Spec::DomainObject.new                         }
  let(:object)        { described_class.new(registry)                  }
  let!(:old_state)    { ROM::Session::State.new(mapper, domain_object) }
  let!(:old_tuple)    { old_state.tuple                                }
  let(:identity)      { state.identity                                 }

  context 'with untracked domain object' do
    it 'should insert' do
      subject
      mapper.inserts.should == [ROM::Session::Operand.new(old_state)]
    end

    it 'should not update' do
      subject
      mapper.updates.should be_empty
    end

    it_should_behave_like 'a command method'
    it_should_behave_like 'an operation that dumps once'

  end

  context 'with tracked domain object' do
    before do
      object.persist(domain_object)
      mapper.inserts.clear
    end

    shared_examples_for 'an update' do
      let(:modified_tuple) do
        { :key_attribute => :a, :other_attribute => :dirty }
      end

      let(:state) do
        mock('State', :object => domain_object, :identity => :a, :tuple => modified_tuple)
      end

      it 'should should update domain object' do
        subject
        mapper.updates.should eql([ROM::Session::Operand::Update.new(state, old_tuple)])
      end

      it 'should not insert' do
        subject
        mapper.inserts.should be_empty
      end

      it_should_behave_like 'a command method'
      it_should_behave_like 'an operation that dumps once'

    end

    # This is a differend test case than the attribute change. 
    # We have to make sure we cache the loaded dump and compare this to 
    # future dumps without storing a dump of an object we just loaded.
    context 'and object is dirty from tuple generation change' do

      before do
        new_dumper = mock('Dump', :identity => identity, :tuple => modified_tuple)
        mapper.stub(:dumper => new_dumper)
      end

      it_should_behave_like 'an update'
    end

    context 'and object is dirty from attribute change' do


      before do
        domain_object.other_attribute = :dirty
      end

      it_should_behave_like 'an update'

    end

    context 'and object is NOT dirty' do
      it 'should not update' do
        subject
        mapper.updates.should be_empty
      end

      it 'should not insert' do
        subject
        mapper.inserts.should be_empty
      end

      it_should_behave_like 'a command method'
      it_should_behave_like 'an operation that dumps once'

    end
  end
end
