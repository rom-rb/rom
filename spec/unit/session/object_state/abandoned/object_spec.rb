require 'spec_helper'

describe Session::ObjectState::Abandoned,'#object' do
  let(:object)        { described_class.new(domain_object,key) }
  let(:key)           { mock                                   }
  let(:domain_object) { DomainObject.new(:foo,:bar)            }

  subject { object.object }

  it 'should return domain object' do
    should == domain_object
  end
end
