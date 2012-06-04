require 'spec_helper'

describe Session::ObjectState::Loaded,'#persist' do
  let!(:object)        { described_class.new(mapper,domain_object) }
  let!(:domain_object) { DomainObject.new(:foo,:bar) }
  let(:mapper)        { DummyMapper.new                           }

  subject { object.persist }

  shared_examples_for 'object state loaded update' do
    it 'should return self' do
      should be(object)
    end

    it 'should store remote key' do
      subject
      object.remote_key.should == expected_remote_key
    end

    it 'should update using the correct key and dump' do
      subject
      mapper.updates.should == [[expected_update_key,expected_update_dump,expected_old_dump]]
    end
  end

  context 'when domain object is unchanged' do
    it 'should return self' do
      should be(object)
    end

    it 'should not do update on mapper' do
      subject
      mapper.updates.should == []
    end
  end

  context 'when domain object is changed' do
    let(:expected_update_key) { :foo }

    context 'and key was modified' do
      before do
        domain_object.key_attribute = :modified
      end

      let(:expected_remote_key)  { :modified }
      let(:expected_update_dump) { { :key_attribute => :modified, :other_attribute => :bar } }
      let(:expected_old_dump)    { { :key_attribute => :foo,      :other_attribute => :bar } }

      it_should_behave_like 'object state loaded update'
    end

    context 'and key was NOT updated' do
      before do
        domain_object.other_attribute = :modified
      end

      let(:expected_remote_key)  { :foo }
      let(:expected_update_dump) { { :key_attribute => :foo,      :other_attribute => :modified } }
      let(:expected_old_dump)    { { :key_attribute => :foo,      :other_attribute => :bar      } }

      it_should_behave_like 'object state loaded update'
    end
  end
end
