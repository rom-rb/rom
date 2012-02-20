require 'spec_helper'

describe Session::Session,'#persist_now' do
  let(:mapper) { DummyMapper.new }
  let(:mapper_root)   { DummyMapperRoot.new(mapper) }

  let(:object) { described_class.new(mapper_root) }

  let(:domain_object) { DomainObject.new }

  subject { object.persist_now(domain_object) }

  context 'when session is committed' do
    it 'should commit session' do
      subject
      object.committed?.should be_true
    end

    context 'when domain object was new' do
      it 'should insert object' do
        subject
        mapper.inserts.should == [domain_object]
      end
    end

    context 'when domain object was loaded and modified' do
      let!(:dump_before) { mapper.dump(domain_object) }

      before do
        object.insert_now(domain_object)
        domain_object.other_attribute = :modified
      end

      it 'should update object' do
        subject
        mapper.updates.should == [[
          domain_object,
          mapper.dump_key(domain_object),
          dump_before
        ]]
      end
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
