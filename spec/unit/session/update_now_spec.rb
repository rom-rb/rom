require 'spec_helper'

describe Session::Session,'#update_now' do
  let(:mapper) { DummyMapper.new }
  let(:root)   { DummyMapperRoot.new(mapper) }
  let(:object) { described_class.new(:root => root) }

  let(:domain_object) { DomainObject.new }

  subject { object.update_now(domain_object) }

  context 'when session is committed' do

    let!(:dump_before) { mapper.dump(domain_object) }

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
        mapper.dump_key(domain_object),
        domain_object,
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
