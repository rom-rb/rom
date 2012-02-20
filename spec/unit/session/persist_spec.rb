require 'spec_helper'

describe Session::Session, '#persist(object)' do
  let(:mapper)       { DummyMapper.new  }
  let(:mapper_root)  { DummyMapperRoot.new(mapper)  }

  let(:object) do 
    described_class.new(mapper_root)
  end

  let(:domain_object) { DomainObject.new }

  subject { object.persist(domain_object) }

  context 'with new domain object' do
    it_should_behave_like 'an insert registration'
   
    context 'when was regstistred as insert' do
      before do
        object.insert(domain_object)
      end
   
      it_should_behave_like 'an insert registration'
    end
  end

  context 'with persisted domain object' do
    context 'with object that was tracked before' do
      before do
        object.insert_now(domain_object)
      end
   
      it_should_behave_like 'an update registration'
    end

    context 'that was registred for delete' do
      before do
        object.insert_now(domain_object)
        object.delete(domain_object)
      end

      it 'should rasie error' do
        expect { subject }.to raise_error
      end
    end
  end
end
