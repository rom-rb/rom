require 'spec_helper'

describe Session::Autocommit,'#update_now' do
  let(:described_class) do
    Class.new(Session::Session) do
      include Session::Autocommit
    end
  end

  let(:mapper)        { registry.resolve_model(DomainObject) }
  let(:registry)      { DummyRegistry.new                    }
  let(:domain_object) { DomainObject.new                     }
  let(:object)        { described_class.new(registry)        }


  subject { object.update_now(domain_object) }

  context 'when session is committed' do

    let!(:dump_before) { mapper.dump(domain_object) }
    let!(:key_before) { mapper.dump_key(domain_object) }

    before do 
      object.insert_now(domain_object)
      domain_object.other_attribute = :dirty
      subject
    end

    it 'should commit session' do
      object.committed?.should be_true
    end

    it 'should update object' do
      mapper.updates.should == [[
        key_before,
        mapper.dump(domain_object),
        dump_before
      ]]
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
