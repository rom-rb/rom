require 'spec_helper'

describe ROM::Session, '#reader(model)' do

  let(:mapper)   { registry.resolve_model(Spec::DomainObject) }
  let(:registry) { Spec::Registry.new                         }
  let(:object)   { described_class.new(registry)              }

  subject { object.reader(Spec::DomainObject) }

  its(:mapper)  { should be(mapper) }
  its(:session) { should be(object) }

  it 'allows to load objects' do
    doc = { :key_attribute => :key, :other_attribute => :other }
    loaded = subject.load(doc)
    loaded.key_attribute.should be(:key)
    loaded.other_attribute.should be(:other)
  end

  it 'does not duplicate load objects when loading twice' do
    doc = { :key_attribute => :key, :other_attribute => :other }
    loaded = subject.load(doc)
    subject.load(doc).should be(loaded)
  end

end
