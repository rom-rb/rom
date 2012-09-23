require 'spec_helper'

describe DataMapper::Utils, '.extract_type' do
  subject { DataMapper::Utils.extract_type(value) }

  context "when args are a hash" do
    let(:value) { {} }

    it { should be_nil }
  end

  context "when args include type" do
    let(:value) { [ type, {} ] }
    let(:type)  { String }

    it { should be(type) }
  end
end
