require 'spec_helper'

describe ROM::Session, '#load' do
  subject { object.load(loader) }

  let(:object)        { described_class.new(registry)                    }
  let(:mapper)        { registry.resolve_model(Spec::DomainObject)       }
  let(:registry)      { Spec::Registry.new                               }
  let(:object)        { described_class.new(registry)                    }
  let(:identity)      { mapper.dumper(domain_object).identity            }
  let(:domain_object) { loader.object                                    }
  let(:tuple)         { { :key_attribute => :a, :other_attribute => :b } }
  let(:loader)        { mapper.loader(tuple)                             }

  context 'when object is not loaded before' do

    it 'should return loaded object' do
      should be(domain_object)
    end

    it 'should track object' do
      expect { subject }.to change { object.include?(domain_object) }.from(false).to(true)
    end

    it 'should track object in tracker' do
      expect { subject }.to change { object.tracker.length }.from(0).to(1)
    end

    it 'should allow to modify object state' do
      subject
      object.delete(domain_object)
    end
  end

  context 'when object is not loaded before' do
    let(:early_object) { mock('Domain Object') }
    let(:early_loader) do
      mock(
        'Loader',
        :identity => identity,
        :object   => early_object,
        :mapper   => mapper
      )
    end

    before do
      object.load(early_loader)
    end

    it 'should return tracked object' do
      should be(early_object)
    end
  end
end
