require 'spec_helper'

describe Session::Session, '#persist(object)' do
  subject { object.persist(domain_object) }

  let(:mapper)        { registry.resolve_model(DomainObject) }
  let(:registry)      { DummyRegistry.new                    }
  let(:domain_object) { DomainObject.new                     }
  let(:object)        { described_class.new(registry)        }

  context 'with untracked domain object' do
    it 'should insert update' do
      subject
      mapper.inserts.should == [mapper.dump(domain_object)]
    end

    it_should_behave_like 'a command method'
  end

  context 'with tracked domain object' do
    let!(:key_before) { mapper.dump_key(domain_object) }
    let!(:dump_before) { mapper.dump(domain_object) }
    let(:identity_map) { object.instance_variable_get(:@identity_map) }

    before do
      object.persist(domain_object)
    end

    context 'and object is dirty' do

      before do
        domain_object.other_attribute = :dirty
      end

      context 'and key did NOT change' do

        it_should_behave_like 'a command method'

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

        it_should_behave_like 'a command method'

        it 'should update domain object under remote key' do
          mapper.updates.should == [[
            key_before, 
            mapper.dump(domain_object), 
            dump_before
          ]]
        end

        it 'should track the domain object under new key' do
          identity_map.fetch(mapper.dump_key(domain_object)).should be(domain_object)
        end

        it 'should NOT track the domain object under old key' do
          identity_map.should_not have_key(key_before)
        end
      end
    end

    context 'and object is NOT dirty' do
      it 'should not update' do
        subject
        mapper.updates.should == []
      end

      it_should_behave_like 'a command method'
    end
  end
end
