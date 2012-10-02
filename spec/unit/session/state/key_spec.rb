require 'spec_helper'

describe Session::State, '#key' do
  subject { object.key }

  let(:class_under_test) { Class.new(described_class) }
  let(:object)           { class_under_test.new(mapper, domain_object) }
  let(:mapper)           { DummyMapper.new                             }
  let(:domain_object)    { DomainObject.new(:foo, :bar)                }

  it_should_behave_like 'an idempotent method'

  it 'should return dumped key representation' do
    should == :foo
  end
end
