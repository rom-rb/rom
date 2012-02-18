require 'spec_helper'

describe Session::Session,'#insert_now' do
  let(:mapper) { DummyMapper.new }
  let(:root)   { DummyMapperRoot.new(mapper) }
  let(:object) { described_class.new(:root => root) }

  let(:domain_object) { DomainObject.new }

  subject { object.insert_now(domain_object) }

  context 'when session is committed' do
    before { subject }

    it 'should commit session' do
      object.committed?.should be_true
    end

    it 'should insert object' do
      mapper.inserts.should == [domain_object]
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
