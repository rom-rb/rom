require 'spec_helper'

describe Session::ObjectState::Loaded,'#remote_key' do
  let!(:object)        { described_class.new(mapper,domain_object) }
  let!(:domain_object) { DomainObject.new(:foo,:bar) }
  let(:mapper)        { DummyMapper.new                           }

  let(:expected_key) { :foo }

  subject { object.remote_key }

  context 'when domain object key is unchanged' do
    it 'should return key stored on last sync' do
      should == :foo
    end
  end

  context 'when domain object key is changed by domain model modification' do
    it 'should return key stored on last sync' do
      domain_object.key_attribute = :modified
      should == :foo
    end
  end

  context 'when domain object key is changed by domain model modification with update' do
    it 'should return key stored on last sync' do
      domain_object.key_attribute = :modified
      object.persist
      should == :modified
    end
  end
end
