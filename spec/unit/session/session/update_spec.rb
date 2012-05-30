require 'spec_helper'

describe Session::Session,'#update' do
  let(:mapper)        { registry.resolve_model(DomainObject) }
  let(:registry)      { DummyRegistry.new                    }
  let(:domain_object) { DomainObject.new                     }
  let(:object)        { described_class.new(registry)        }

  let(:identity_map)  { object.instance_variable_get(:@identity_map) }


  subject { object.update(domain_object) }

  let!(:dump_before) { mapper.dump(domain_object) }
  let!(:key_before) { mapper.dump_key(domain_object) }

  context 'when domain object is tracked' do
    before do 
      object.insert(domain_object)
    end

    context 'and dirty' do
      before do
        domain_object.other_attribute = :dirty
      end

      context 'and key did NOT change' do


        it 'should update domain object under remote key' do
          subject
          mapper.updates.should == [[
            key_before,
            mapper.dump(domain_object),
            dump_before
          ]]
        end
      end

      context 'and key did change' do

        before do
          domain_object.key_attribute = :dirty
          subject
        end

        it 'should update domain object under remote key' do
          mapper.updates.should == [[
            key_before,
            mapper.dump(domain_object),
            dump_before
          ]]
        end

        it 'should track the domain object under new key' do
          identity_map.fetch(mapper.dump_key(domain_object)).should == domain_object
        end

        it 'should NOT track the domain object under old key' do
          identity_map.should_not have_key(key_before)
        end
      end
    end

    context 'and NOT dirty' do
      it 'should not update' do
        subject
        mapper.updates.should == []
      end
    end
  end

  context 'when domain object is NOT tracked' do
    it 'should raise error' do
      expect { subject }.to raise_error(Session::StateError,"#{domain_object.inspect} is not tracked")
    end
  end
end
