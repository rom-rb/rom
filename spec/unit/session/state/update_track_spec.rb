require 'spec_helper'

describe Session::State, '#update_track' do
  subject { object.update_track(track) }

  let(:class_under_test) { Class.new(described_class)                  }
  let(:object)           { class_under_test.new(mapper, domain_object) }
  let(:mapper)           { DummyMapper.new                             }
  let(:domain_object)    { DomainObject.new(:foo, :bar)                }
  let(:track)            { {}.freeze                                   }

  it_should_behave_like 'a command method'

  it 'should not touch track' do
    subject
  end

  it 'should return self' do
    should be(object)
  end
end
