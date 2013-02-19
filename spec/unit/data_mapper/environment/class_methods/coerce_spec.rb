require 'spec_helper'

describe Environment, '.coerce' do
  subject { described_class.coerce(config) }

  context "when an environment is passed" do
    let(:config)      { environment }
    let(:environment) { described_class.new('test' => 'in_memory://test') }

    it { should be(environment) }
  end

  context "when a repository config hash is passed" do
    let(:config) { { name => uri } }
    let(:name)   { 'test' }
    let(:uri)    { 'in_memory://test' }

    let(:coerced_config) { { :test => Repository.coerce(name, coerced_uri) } }
    let(:coerced_uri)    { Addressable::URI.parse(uri) }

    it { should eq(described_class.new(coerced_config)) }
  end
end
