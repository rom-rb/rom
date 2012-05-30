require 'spec_helper'

describe Session::ObjectState::Loaded,'#delete' do
  let(:object)        { described_class.new(mapper,domain_object) }
  let(:mapper)        { DummyMapper.new                           }
  let(:domain_object) { DomainObject.new(:foo,:bar) }

  subject { object.delete }

  it 'should delete object' do
    subject
    mapper.deletes.should == [object.remote_key]
  end

  # Returning a new state does not make sense. 
  # As this is a command method it should return self. 
  # But this self is not valid anymore, so I decided to violate CQS here.
  it 'should return nil' do
    should be_nil
  end
end
