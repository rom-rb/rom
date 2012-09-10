require 'spec_helper'

describe Session::ObjectState, '#object' do
  let(:object)        { class_under_test.new(mapper, domain_object) }
  let(:mapper)        { DummyMapper.new                             }
  let(:domain_object) { DomainObject.new(:foo, :bar) }

  subject { object.object }

  let(:class_under_test) do
    Class.new(described_class)
  end

  it_should_behave_like 'an idempotent method'

  it 'should return domain object' do
    should be(domain_object)
  end
end
