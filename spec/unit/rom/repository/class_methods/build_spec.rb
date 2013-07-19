require 'spec_helper'

describe Repository, '.build' do
  subject { described_class.build(name, uri) }

  let(:name) { :test }

  context "with a registered uri scheme" do
    let(:uri) { Addressable::URI.parse('memory://test') }

    it { should be_instance_of(described_class) }

    its(:name)    { should be(name) }
    its(:adapter) { should eq(Axiom::Adapter.build(uri)) }
  end

  context "with an unregistered uri scheme" do
    let(:uri) { Addressable::URI.parse('unregistered://test') }
    let(:msg) { "'#{uri.scheme}' is no registered uri scheme" }

    specify do
      expect { subject }.to raise_error(Axiom::UnknownAdapterError, msg)
    end
  end
end
