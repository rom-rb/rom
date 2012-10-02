require 'spec_helper'

describe Session::State, '#update_tracker' do
  subject { object.update_tracker(tracker) }

  let(:class_under_test) { Class.new(described_class)                  }
  let(:object)           { class_under_test.new(mapper, domain_object) }
  let(:mapper)           { DummyMapper.new                             }
  let(:domain_object)    { DomainObject.new(:foo, :bar)                }
  let(:tracker)          { {}.freeze                                   }

  it_should_behave_like 'a command method'

  it 'should not touch tracker' do
    subject
  end

  it_should_behave_like 'a command method'
end
