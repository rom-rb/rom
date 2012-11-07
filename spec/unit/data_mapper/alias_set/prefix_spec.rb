require 'spec_helper'

describe AliasSet, '#prefix' do
  subject { object.prefix }

  let(:object) { described_class.new(prefix) }
  let(:prefix) { :songs }

  it { should == prefix }
end
