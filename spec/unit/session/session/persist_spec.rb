require 'spec_helper'

describe Session::Session, '#persist(object)' do
  let(:mapper)        { registry.resolve_model(DomainObject) }
  let(:registry)      { DummyRegistry.new                    }
  let(:domain_object) { DomainObject.new                     }
  let(:object)        { described_class.new(registry)        }

  subject { object.persist(domain_object) }

  context 'with untracked domain object' do
    # this tests implemenation but feels so nice
    it 'should behave like #insert(object)' do
      object.should_receive(:insert).with(domain_object)
      subject
    end
  end

  context 'with tracked domain object' do
    before do
      object.insert(domain_object)
    end

    # this tests implemenation but feels so nice
    it 'should behave like #update(object)' do
      object.should_receive(:update).with(domain_object)
      subject
    end
  end
end
