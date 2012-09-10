require 'spec_helper'

describe Session::ObjectState, '#delete_identity' do
  subject { object.delete_identity(identity_map) }

  let(:class_under_test) { Class.new(described_class)                                 }
  let(:object)           { class_under_test.new(mapper, domain_object)                }
  let(:mapper)           { DummyMapper.new                                            }
  let(:domain_object)    { DomainObject.new(:foo, :bar)                               }
  let(:identity_map)     { { mapper.dump_key(domain_object) => domain_object }.freeze }

  it_should_behave_like 'a command method'

  it 'should not touch identity map' do
    subject
  end

  it 'should return self' do
    should be(object)
  end
end
