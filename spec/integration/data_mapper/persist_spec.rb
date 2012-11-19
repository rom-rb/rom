require 'spec_helper'

describe DataMapper::Session, '#persist' do
  subject { object.persist(domain_object) }

  let(:mapper)        { registry.resolve_model(Spec::DomainObject)                                  }
  let(:registry)      { Spec::Registry.new                                                          }
  let(:domain_object) { Spec::DomainObject.new                                                      }
  let(:object)        { described_class.new(registry)                                               }
  let(:identity_map)  { object.instance_variable_get(:@tracker).instance_variable_get(:@identities) }
  let(:mapping)       { DataMapper::Session::Mapping.new(mapper, domain_object)                     }
  let(:new_identity)  { mapper.dumper(domain_object).identity                                       }
  let!(:old_identity) { mapper.dumper(domain_object).identity                                       }
  let!(:old_body)     { mapper.dumper(domain_object).body                                           }
  let!(:old_state)    { DataMapper::Session::State::Loaded.new(mapping)                             }

  context 'with untracked domain object' do
    it 'should insert update' do
      subject
      mapper.inserts.should == [
        DataMapper::Session::State::New.new(mapping)
      ]
    end

    it_should_behave_like 'a command method'

    it_should_behave_like 'an operation that dumps once'
  end

  context 'with tracked domain object' do
    let(:new_identity)      { mapper.dumper(domain_object).identity  }

    before do
      object.persist(domain_object)
    end

    shared_examples_for 'an update' do
      it 'should should update domain object' do
        subject
        mapper.updates.should eql([[
          DataMapper::Session::State::Dirty.new(mapping),
          old_state
        ]])
      end

      it_should_behave_like 'an operation that dumps once'

      it 'should track the domain object under new identity' do
        subject
        identity_map.fetch(new_identity).object.should be(domain_object)
      end

      it 'should NOT track the domain object under old identity' do
        subject

        if old_identity != new_identity
          identity_map.should_not have_key(old_identity)
        end
      end

      it_should_behave_like 'a command method'
    end

    # This is a differend test case than the attribute change. 
    # We have to make sure we cache the loaded dump and compare this to 
    # future dumps without storing a dump of an object we just loaded.
    context 'and object is dirty from dump representation change' do
      before do
        new_dumper = mock(:identity => :changed, :body => :other_change)
        mapper.stub(:dumper => new_dumper)
      end

      it_should_behave_like 'an update'
    end

    context 'and object is dirty from attribute change' do

      before do
        domain_object.other_attribute = :dirty
      end

      context 'and identity did NOT change' do
        it_should_behave_like 'an update'
      end

      context 'and identity did change' do
        let(:new_identity) { :dirty }

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
