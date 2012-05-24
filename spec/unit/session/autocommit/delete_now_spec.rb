require 'spec_helper'

describe Session::Autocommit,'#delete_now' do
  let(:described_class) do
    Class.new(Session::Session) do
      include Session::Autocommit
    end
  end

  let(:mapper)        { registry.resolve_model(DomainObject) }
  let(:registry)      { DummyRegistry.new                    }
  let(:domain_object) { DomainObject.new                     }
  let(:object)        { described_class.new(registry)        }

  subject { object.delete_now(domain_object) }

  context 'when session is committed' do
    let!(:key_before) { mapper.dump_key(domain_object) }

    before do
      object.insert_now(domain_object)
      subject
    end

    it 'should commit session' do
      object.committed?.should be_true
    end

    it 'should delete object' do
      mapper.deletes.should == [key_before]
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
