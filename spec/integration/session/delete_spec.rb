require 'spec_helper'

describe Session::Session, '#delete' do
  let(:mapper)        { registry.resolve_model(DomainObject)         }
  let(:registry)      { DummyRegistry.new                            }
  let(:domain_object) { DomainObject.new                             }
  let(:object)        { described_class.new(registry)                }
  let(:mapping)       { Session::Mapping.new(mapper, domain_object)  }

  let(:identity_map)  { object.instance_variable_get(:@identity_map) }

  subject { object.delete(domain_object) }

  let!(:key) { mapper.dump_key(domain_object) }

  context 'when domain object is tracked' do
    before do
      object.persist(domain_object)
      subject
    end

    it 'should delete object' do
      mapper.deletes.should == [Session::State::Loaded.new(mapping)]
    end

    it 'should not dump' do
      mapper.should_not_receive(:dump)
      mapper.should_not_receive(:dump_key)

      subject
    end

    it 'should not track object anymore' do
      object.include?(domain_object).should be(false)
    end

    it 'should remove domain object from identity_map' do
      identity_map.should_not have_key(key)
    end

    it_should_behave_like 'a command method'
  end

  context 'when domain object is NOT tracked' do
    it 'should raise error' do
      expect { subject }.to raise_error(Session::StateError, "#{domain_object.inspect} is not tracked")
    end
  end
end
