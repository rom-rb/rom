# encoding: utf-8

require 'spec_helper'

describe Environment, '.coerce' do
  subject { described_class.coerce(config) }

  context 'when an environment is passed' do
    let(:config)      { environment }
    let(:environment) { described_class.build(test: 'memory://test') }

    it { should be(environment) }
  end

  context 'when a repository config hash is passed' do
    let(:config) { { name => uri } }
    let(:name)   { :test }
    let(:uri)    { 'memory://test' }

    let(:coerced_config) { Hash[test: Repository.build(name, coerced_uri)] }
    let(:coerced_uri)    { Addressable::URI.parse(uri) }

    it { should eq(described_class.build(coerced_config)) }
  end
end
