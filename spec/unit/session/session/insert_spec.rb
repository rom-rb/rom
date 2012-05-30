require 'spec_helper'

describe Session::Session,'#insert' do
  let(:mapper)        { registry.resolve_model(DomainObject) }
  let(:registry)      { DummyRegistry.new                    }
  let(:domain_object) { DomainObject.new                     }
  let(:object)        { described_class.new(registry)        }

  let(:identity_map)  { object.instance_variable_get(:@identity_map) }

  subject { object.insert(domain_object) }

  context 'when domain object is NOT already tracked' do
    before do
      subject
    end

    it 'should insert object' do
      mapper.inserts.should == [mapper.dump(domain_object)]
    end

    it 'should track domain object' do
      object.track?(domain_object).should be_true
    end

    it 'should add domain object to identity map' do
      identity_map[mapper.dump_key(domain_object)].should == domain_object
    end
  end

  context 'when domain object is already tracked' do
    before do
      object.insert(domain_object)
    end

    it 'should raise error' do
      expect { subject }.to raise_error(RuntimeError,"#{domain_object.inspect} is already tracked and cannot be inserted")
    end
  end
end
