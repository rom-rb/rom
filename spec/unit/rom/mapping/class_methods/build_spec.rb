# encoding: utf-8

require 'spec_helper'

describe Mapping, '.build' do
  let(:header)   { [[:id, Integer], [:user_name, String], [:age, Integer], [:email, String]] }
  let(:relation) { Axiom::Relation::Base.new(:users, header) }
  let(:env)      { Hash[users: relation] }
  let(:registry) { Hash.new }

  context 'when attribute mapping is used' do
    subject do
      Mapping.build(env, registry) do
        users do
          map :id, :email
          map :user_name, to: :name
        end
      end
    end

    before do
      stub(env).[](:users) { relation }
    end

    it 'registers rom relation' do
      expect(subject[:users]).to be_instance_of(Relation)
    end

    it 'builds rom mapper' do
      mapper = subject[:users].mapper

      expect(mapper.header.map(&:name)).to eql([:id, :email, :name])
    end
  end

  context 'when registry is not injected' do
    subject { Mapping.build(env) { } }

    it { should be_instance_of(Hash) }
  end

  context 'when unknown relation name is used' do
    subject { described_class.build(env, registry) { not_here {} } }

    it 'raises error' do
      expect { subject }.to raise_error(NoMethodError)
    end
  end
end
