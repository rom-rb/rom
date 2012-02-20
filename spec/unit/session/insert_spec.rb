require 'spec_helper'

describe Session::Session, '#insert(object)' do
  let(:mapper)       { DummyMapper.new  }
  let(:mapper_root)  { DummyMapperRoot.new(mapper)  }

  let(:object) do 
    described_class.new(mapper_root)
  end

  let(:domain_object) { DomainObject.new }

  subject { object.insert(domain_object) }

  shared_examples_for 'a failing insert registration' do
    it 'should raise error' do
      expect do
        subject
      end.to raise_error
    end
  end

  context 'with new domain object' do
    context 'when was NOT registred as insert' do
      it 'it should NOT be marked as insert' do
        object.insert?(domain_object).should be_false
      end

      it 'should NOT track domain object' do
        object.track?(domain_object).should be_false
      end

      it_should_behave_like 'an insert registration'
    end
   
    context 'when was regstistred as insert' do
      before do
        object.insert(domain_object)
      end
   
      it_should_behave_like 'an insert registration'
    end
  end

  context 'with object that was tracked before' do
    before do
      object.insert_now(domain_object)
    end

    it_should_behave_like 'a failing insert registration'
  end
end
