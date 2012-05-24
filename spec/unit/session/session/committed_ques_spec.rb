require 'spec_helper'

describe Session::Session,'#committed?' do
  let(:mapper)        { registry.resolve_model(DomainObject) }
  let(:registry)      { DummyRegistry.new                    }
  let(:domain_object) { DomainObject.new                     }
  let(:object)        { described_class.new(registry)        }

  subject { object.committed? }

  context 'when session NOT has uncommitted work' do
    it { should be_true }
  end

  context 'when session has uncommited work' do
    before do 
      object.insert(domain_object)
    end

    it { should be_false }
  end
end
