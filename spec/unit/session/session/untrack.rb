require 'spec_helper'

describe Session::Session,'#untrack' do
  let(:mapper)       { DummyMapper.new  }
  let(:mapper_root)  { REGISTRY.new(mapper)  }

  let(:object) do 
    described_class.new(mapper_root)
  end

  let(:domain_object) { DomainObject.new }

  subject { object.untrack(domain_object) }

  context 'when object was tracked' do
    before do
      object.insert_now(domain_object)
    end

    it 'should untrack object' do
      subject
      object.track?(domain_object).should be_false
    end
  end
end
