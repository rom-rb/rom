require 'spec_helper'

describe AttributeSet, '#attributes' do
  subject { object.attributes }

  let(:object) { described_class.new }

  it { should == {} }
end
