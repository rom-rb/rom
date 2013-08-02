# encoding: utf-8

require 'spec_helper'

describe Schema, '.build' do
  include_context 'Environment'

  let(:registry) { Hash[test: repository] }

  let(:keys) { [:id] }

  let(:schema) {
    key_args = keys

    described_class.build(registry) do
      base_relation :users do
        repository :test

        attribute :id,   Integer
        attribute :name, String

        key(*key_args)
      end
    end
  }

  let(:header) {
    Axiom::Relation::Header.coerce([[:id, Integer], [:name, String]], keys: keys)
  }

  let(:relation) {
    Axiom::Relation::Base.new(:users, header)
  }

  fake(:repository)
  fake(:gateway) { Axiom::Relation }

  before do
    stub(repository).[]=(:users, relation) { gateway }
    stub(repository).[](:users) { gateway }
  end

  def self.it_registers_relation
    it 'registers base relation in the repository' do
      expect(subject[:users]).to be(gateway)
      expect(repository).to have_received.[]=(:users, relation)
    end
  end

  context 'defining base relations' do
    subject { schema }

    context 'with a single key' do
      it_registers_relation
    end

    context 'with multiple keys' do
      let(:keys) { [:id, :name] }

      it_registers_relation
    end
  end

  context 'defining relations' do
    subject do
      schema.call do
        relation :restricted_users do
          users.restrict(name: 'Jane')
        end
      end
    end

    it 'registers restricted relation' do
      stub(gateway).restrict(name: 'Jane') { gateway }

      expect(subject[:restricted_users]).to be(gateway)

      expect(gateway).to have_received.restrict(name: 'Jane')
    end

    context 'when invalid relation name is used' do
      subject do
        schema.call do
          relation :restricted_users do
            not_here.restrict
          end
        end
      end

      it 'raises error' do
        expect { subject }.to raise_error(
          NameError, /undefined local variable or method `not_here'/
        )
      end
    end
  end

  context 'without block' do
    subject { Schema.build({}) }

    it { should be_instance_of(Schema) }
  end
end
