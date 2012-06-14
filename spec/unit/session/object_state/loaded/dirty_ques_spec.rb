require 'spec_helper'

describe Session::ObjectState::Loaded,'#dirty?' do
  let!(:object)        { described_class.new(mapper,domain_object) }
  let(:mapper)        { DummyMapper.new                           }
  let!(:domain_object) { DomainObject.new(:foo,:bar) }

  context 'with dump provided' do
    subject { object.dirty?(dump) }


    context 'when dump matches objects dump' do
      let(:dump) { { :key_attribute => :foo,:other_attribute => :bar } }
      it { should be(false) }

      it_should_behave_like 'an idempotent method'
    end

    context 'when dump does NOT match object dump' do
      let(:dump) { { :foo => :bar } }
      it { should be(true) }

      it_should_behave_like 'an idempotent method'
    end
  end

  context 'without dump provided' do
    subject { object.dirty? }

    it_should_behave_like 'an idempotent method'

    context 'and domain object is unchanged' do
      it { should be(false) }
      it_should_behave_like 'an idempotent method'
    end

    context 'and domain object is changed' do
      before do
        domain_object.other_attribute = :modification
      end

      it_should_behave_like 'an idempotent method'
      it { should be(true) }
    end
  end
end

