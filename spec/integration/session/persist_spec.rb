require 'spec_helper'

describe Session::Session, '#persist' do
  subject { object.persist(domain_object) }

  let(:mapper)        { registry.resolve_model(DomainObject)         }
  let(:registry)      { DummyRegistry.new                            }
  let(:domain_object) { DomainObject.new                             }
  let(:object)        { described_class.new(registry)                }
  let(:identity_map)  { object.instance_variable_get(:@tracker).instance_variable_get(:@identities) }
  let(:mapping)       { Session::Mapping.new(mapper, domain_object)  }
  let(:new_key)       { mapper.dump_key(domain_object)               }
  let!(:old_key)      { mapper.dump_key(domain_object)               }
  let!(:old_dump)     { mapper.dump(domain_object)                   }
  let!(:old_state)    { Session::State::Loaded.new(mapping)          }
  let!(:old_identity) { Session::Identity.new(DomainObject, old_key) }
  let!(:new_identity) { Session::Identity.new(DomainObject, new_key) }

  context 'with untracked domain object' do
    it 'should insert update' do
      subject
      mapper.inserts.should == [
        Session::State::New.new(mapping)
      ]
    end

    it_should_behave_like 'a command method'

    it_should_behave_like 'an operation that dumps once'
  end

  context 'with tracked domain object' do
    let(:new_dump)     { mapper.dump(domain_object) }
    let(:new_key)      { mapper.dump_key(domain_object) }

    before do
      object.persist(domain_object)
    end

    shared_examples_for 'an update' do
      it 'should should update domain object' do
        subject
        mapper.updates.should eql([[
          Session::State::Dirty.new(mapping),
          old_state
        ]])
      end

      it_should_behave_like 'an operation that dumps once'

      it 'should track the domain object under new key' do
        subject
        identity_map.fetch(new_identity).object.should be(domain_object)
      end

      it 'should NOT track the domain object under old key' do
        subject

        if old_key != new_key
          identity_map.should_not have_key(old_identity)
        end
      end

      it_should_behave_like 'a command method'
    end

    # This is a differend test case than the attribute change. 
    # We have to make sure we cache the loaded dump and compare this to 
    # future dumps without storing a dump of an object we just loaded.
    context 'and object is dirty from dump representation change' do
      let(:new_dump) { { :some => :change } }

      before do
        mapper.stub(:dump => new_dump)
      end

      it_should_behave_like 'an update'
    end

    context 'and object is dirty from attribute change' do

      before do
        domain_object.other_attribute = :dirty
      end

      context 'and key did NOT change' do
        it_should_behave_like 'an update'
      end

      context 'and key did change' do
        let(:new_key) { :dirty }

        before do
          domain_object.key_attribute = :dirty
        end

        it_should_behave_like 'an update'
      end
    end

    context 'and object is NOT dirty' do
      it 'should not update' do
        subject
        mapper.updates.should == []
      end

      it_should_behave_like 'an operation that dumps once'

      it_should_behave_like 'a command method'
    end
  end
end
