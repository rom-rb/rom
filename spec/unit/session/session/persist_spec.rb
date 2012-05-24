require 'spec_helper'

describe Session::Session, '#persist(object)' do
  let(:mapper)        { registry.resolve_model(DomainObject) }
  let(:registry)      { DummyRegistry.new                    }
  let(:domain_object) { DomainObject.new                     }
  let(:object)        { described_class.new(registry)        }

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
        object.insert(domain_object).commit
      end
   
      it_should_behave_like 'an update registration'
    end

    context 'that was registred for delete' do
      before do
        object.insert(domain_object).commit
        object.delete(domain_object)
      end

      it 'should unregister delete' do
        subject
        object.delete?(domain_object).should be_false
      end
    end
  end
end
