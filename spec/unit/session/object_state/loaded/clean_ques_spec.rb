require 'spec_helper'

describe Session::ObjectState::Loaded,'#clean?' do
  let!(:object)        { described_class.new(mapper,domain_object) }
  let(:mapper)        { DummyMapper.new                           }
  let!(:domain_object) { DomainObject.new(:foo,:bar) }

  context 'with dump provided' do
    subject { object.clean?(dump) }

    context 'when dump matches objects dump' do
      let(:dump) { { :key_attribute => :foo,:other_attribute => :bar } }
      it { should be_true }
    end

    context 'when dump does NOT match object dump' do
      let(:dump) { { :foo => :bar } }
      it { should be_false }
    end
  end

  context 'without dump provided' do
    subject { object.clean? }

    context 'and domain object is unchanged' do
      it { should be_true }
    end

    context 'and domain object is changed' do
      before do
        domain_object.other_attribute = :modification
      end

      it { should be_false }
    end
  end
end

