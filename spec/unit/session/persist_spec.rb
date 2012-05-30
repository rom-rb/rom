require 'spec_helper'

describe Session::Session,'#persist' do
  let(:mapper)        { registry.resolve_model(DomainObject) }
  let(:registry)      { DummyRegistry.new                    }
  let(:domain_object) { DomainObject.new                     }
  let(:object)        { described_class.new(registry)        }

  subject { object.persist(domain_object) }

  context 'when domain object is new' do
    it 'should insert object' do
      subject
      mapper.inserts.should == [mapper.dump(domain_object)]
    end
  end

  context 'when domain object is loaded' do
    context 'and was modified' do
      let!(:dump_before) { mapper.dump(domain_object) }

      before do
        object.insert(domain_object)
        domain_object.other_attribute = :modified
      end

      it 'should update object' do
        subject
        mapper.updates.should == [[
          mapper.load_key(dump_before),
          mapper.dump(domain_object),
          dump_before
        ]]
      end
    end

    context 'and was NOT modified' do
      it 'should do nothing' do
        subject
        mapper.updates.should == []
      end
    end
  end
end
