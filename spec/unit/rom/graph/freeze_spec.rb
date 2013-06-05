require 'spec_helper'

describe Graph, '#freeze' do
  subject { object.freeze }

  let(:object) { described_class.new }

  it { should be_frozen }

  its(:nodes)      { should be_frozen }
  its(:edges)      { should be_frozen }
  its(:connectors) { should be_frozen }
end
