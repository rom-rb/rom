require 'spec_helper'

describe DataMapper::Session, '#delete' do
  let(:mapper)        { registry.resolve_model(Spec::DomainObject)         }
  let(:registry)      { Spec::Registry.new                            }
  let(:domain_object) { Spec::DomainObject.new                             }
  let(:object)        { described_class.new(registry)                }
  let(:mapping)       { DataMapper::Session::Mapping.new(mapper, domain_object)  }

  let(:identity_map)  { object.instance_variable_get(:@tracker).instance_variable_get(:@identities) }

  subject { object.delete(domain_object) }

  let!(:key) { mapper.dumper(domain_object).key }

  context 'when domain object is tracked' do
    before do
      object.persist(domain_object)
    end

    it 'should delete object' do
      subject
      mapper.deletes.should == [DataMapper::Session::State::Loaded.new(mapping)]
    end

    it 'should not dump' do
      mapper.should_not_receive(:dumper)

      subject
    end

    it 'should not track object anymore' do
      subject
      object.include?(domain_object).should be(false)
    end

    it 'should remove domain object from identity_map' do
      subject
      identity_map.should_not have_key(key)
    end

    it_should_behave_like 'a command method'
  end

  context 'when domain object is NOT tracked' do
    it 'should raise error' do
      expect { subject }.to raise_error(DataMapper::Session::StateError, "#{domain_object.inspect} is not tracked")
    end
  end
end
