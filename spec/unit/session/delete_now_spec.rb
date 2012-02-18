require 'spec_helper'

describe Session::Session,'#delete_now' do
  let(:mapper) { DummyMapper.new }
  let(:root)   { DummyMapperRoot.new(mapper) }
  let(:object) { described_class.new(:root => root) }

  let(:domain_object) { DomainObject.new }

  subject { object.delete_now(domain_object) }

  context 'when session is committed' do
    before do
      object.insert_now(domain_object)
      subject
    end

    it 'should commit session' do
      object.committed?.should be_true
    end

    it 'should delete object' do
      mapper.deletes.should == [domain_object]
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
