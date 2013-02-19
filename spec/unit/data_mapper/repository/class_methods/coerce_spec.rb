require 'spec_helper'

describe Repository, '.coerce' do
  subject { described_class.coerce(name, uri) }

  let(:name) { :test }

  context "with a registered uri scheme" do
    let(:uri) { Addressable::URI.parse('in_memory://test') }

    it { should be_instance_of(described_class) }

    its(:name)    { should be(name) }
    its(:adapter) { should eq(Veritas::Adapter.new(uri)) }
  end

  context "with an unregistered uri scheme" do
    let(:uri) { Addressable::URI.parse('unregistered://test') }
    let(:msg) { "'#{uri.scheme}' is no registered uri scheme" }

    specify do
      expect { subject }.to raise_error(Veritas::UnknownAdapterError, msg)
    end
  end
end
