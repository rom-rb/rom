require 'spec_helper'

describe Session::Session,'#commit' do
  let(:mapper)        { registry.resolve_model(DomainObject) }
  let(:registry)      { DummyRegistry.new                    }
  let(:domain_object) { DomainObject.new                     }
  let(:object)        { described_class.new(registry)        }

  let(:identity_map)  { object.instance_variable_get(:@identity_map) }

  subject { object.commit }

  shared_examples_for 'a committed session' do
    it 'should NOT tell it is uncommitted' do
      object.should_not be_uncommitted
    end

    it 'should tell it is committed' do
      object.should be_committed
    end
  end

  context 'when there was no interaction' do
    before do
      subject
    end

    it_should_behave_like 'a committed session'
  end

  context 'when a domain object was marked for update' do
    let!(:key_before)  { mapper.dump_key(domain_object) }
    let!(:dump_before) { mapper.dump(domain_object)     }

    context 'and domain object was modified' do
      shared_examples_for 'a commit with updates' do
        it_should_behave_like 'a committed session'

        it 'should update with the correct key' do
          mapper.updates.should == [[
            key_before,
            mapper.dump(domain_object),
            dump_before
          ]]
        end
      end

      context 'and key did change' do
        before do
          object.insert(domain_object).commit
          domain_object.key_attribute = :modified
          object.update(domain_object)
          subject
        end

        it_should_behave_like 'a commit with updates'

        it 'should unregister old key from identity map' do
          identity_map.should_not have_key(key_before)
        end

        it 'should register new key in identity map' do
          identity_map.fetch(:modified).should == domain_object
        end
      end

      context 'and key did not change' do
        before do
          object.insert(domain_object).commit
          domain_object.other_attribute = :mutated_value
          object.update(domain_object)
          subject
        end

        it_should_behave_like 'a commit with updates'
      end
    end

    context 'when domain object was NOT modified' do
      before do
        object.insert(domain_object).commit
        object.update(domain_object)
        subject
      end
     
      it_should_behave_like 'a committed session'
     
      it 'should NOT forward the update to mapper' do
        mapper.updates.should == []
      end
    end
  end

  context 'when a domain object was marked for delete' do
    let!(:key_before) { mapper.dump_key(domain_object) }

    before do
      object.insert(domain_object).commit
      object.delete(domain_object)
      subject
    end


    it_should_behave_like 'a committed session'

    it 'should forward the delete to mapper' do
      mapper.deletes.should == [key_before]
    end

    it 'should remove from identity map' do
      identity_map.key?(mapper.dump_key(domain_object)).should be_false
    end
  end

  context 'when a domain object was marked for insert' do
    before do
      object.insert(domain_object)
      subject
    end

    it_should_behave_like 'a committed session'

    it 'should forward the insert to mapper' do
      mapper.inserts.should == [mapper.dump(domain_object)]
    end

    it 'should insert into identity map' do
      identity_map.fetch(mapper.dump_key(domain_object)).should == domain_object
    end
  end
end
