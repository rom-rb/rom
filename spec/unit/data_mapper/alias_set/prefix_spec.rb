require 'spec_helper'

describe AliasSet, '#prefix' do
  subject { object.prefix }

  let(:object) { described_class.new(relation_name) }
  let(:relation_name) { :songs }

  it { should == :song }
end
