require 'spec_helper'

describe Session::Autocommit,'#insert_now' do
  let(:described_class) do
    Class.new(Session::Session) do
      include Session::Autocommit
    end
  end

  let(:mapper)        { registry.resolve_model(DomainObject) }
  let(:registry)      { DummyRegistry.new                    }
  let(:domain_object) { DomainObject.new                     }
  let(:object)        { described_class.new(registry)        }

  subject { object.insert_now(domain_object) }

  context 'when session is committed' do
    before { subject }

    it 'should commit session' do
      object.committed?.should be_true
    end

    it 'should insert object' do
      mapper.inserts.should == [mapper.dump(domain_object)]
    end
  end

  context 'when session is uncommitted' do
    before do
      object.insert(Object.new) 
    end

    it 'should raise error' do
      expect { subject }.to raise_error
    end
  end
end
