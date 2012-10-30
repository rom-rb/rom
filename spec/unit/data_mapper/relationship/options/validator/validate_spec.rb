require 'spec_helper'

describe Relationship::Options::Validator, '#initialize' do
  subject { object.validate }

  let(:object) { described_class.new({}) }

  it { should be_nil }
end
