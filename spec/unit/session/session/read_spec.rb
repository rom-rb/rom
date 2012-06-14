require 'spec_helper'

describe Session::Session,'#read' do
  let(:mapper)        { registry.resolve_model(DomainObject)   }
  let(:registry)      { DummyRegistry.new                      }
  let(:domain_object) { DomainObject.new                       }
  let(:object)        { described_class.new(registry)          }
  let(:mapper)        { registry.resolve_object(domain_object) }
  let(:query)         { mock }

  subject { object.read(DomainObject,query) }
  
  context 'with arguments' do
    it 'should pass arguments to Mapper#wrap_query' do
      mapper.should_receive(:wrap_query).with(query)
      subject
    end
  end

  context 'with block' do
    let(:block) { proc {} }

    subject { object.read(DomainObject,&block) }
    it 'should pass block to Mapper#wrap_query' do
      mapper.should_receive(:wrap_query).with(block)
      subject
    end
  end

  context 'when no dumps are selected' do
    before do
      mapper.dumps=[]
    end

    it 'should return empty array' do
      should == []
    end
  end

  context 'when dumps are selected' do
    before do
      mapper.dumps = [mapper.dump(domain_object)]
    end

    context 'and domain objects where not tracked before' do
      it 'should return array with newly loaded domain object' do
        domain_objects = subject
        domain_objects.length.should == 1
        loaded = domain_objects.first
        loaded.should be_kind_of(DomainObject)
        loaded.key_attribute.should == domain_object.key_attribute
        loaded.other_attribute.should == domain_object.other_attribute
      end

      it 'should track loaded domain object' do
        object.should include(subject.first)
      end
    end

    context 'and dumps are tracked' do
      let(:tracked) { object.read(DomainObject,query).first }

      it 'should return already tracked domain object' do
        subject.first.should be(tracked)
      end
    end
  end
end
