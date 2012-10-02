require 'spec_helper'

describe Session::Session, 'with unit of work' do

  let(:mapper)        { registry.resolve_model(DomainObject) }
  let(:object)        { described_class.new(work)            }
  let(:work)          { Session::Work.new(registry)          }
  let(:registry)      { DummyRegistry.new                    }
  let(:domain_object) { DomainObject.new                     }

  specify 'allows to execute a group of commands' do
    a = DomainObject.new(:key_attribute => :a, :other_attribute => :foo)
    b = DomainObject.new(:key_attribute => :a, :other_attribute => :bar)

    object.persist(a)
    object.persist(b)

    a.other_attribute = :baz
    object.persist(a)

    object.delete(b)

    mapper.inserts.should eql([])
    mapper.updates.should eql([])
    mapper.deletes.should eql([])

    work.flush

    mapper.inserts.length.should be(2)
    mapper.updates.length.should be(1)
    mapper.deletes.length.should be(1)
  end
end
