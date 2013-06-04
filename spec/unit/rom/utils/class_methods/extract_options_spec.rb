require 'spec_helper'

describe ROM::Utils, '.extract_options' do
  subject { described_class.extract_options(value) }


  context "when options responds to :to_hash" do
    let(:value)        { [ 'foo', options ] }
    let(:options)      { mock('options', :to_hash => options_hash) }
    let(:options_hash) { { :a => 1, :b => 2 } }

    it { should     eql(options_hash) }
    it { should_not be(options_hash)  }
  end

  context "when options doesn't respond to :to_hash" do
    let(:value) { [ 'foo' ] }

    it { should eql({}) }
  end
end
