# encoding: utf-8

require 'spec_helper'

describe Schema::Builder, '#call' do
  subject(:schema) { described_class.new(test: repository) }

  let(:keys) { [:id] }

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

  context 'defining base relations' do

    context 'with repository' do

      def self.it_registers_relation
        it 'registers base relation in the repository' do
          expect(schema[:users]).to be(gateway)
          expect(repository).to have_received.[]=(:users, relation)
        end
      end

      before do
        key_args = keys

        schema.call do
          base_relation :users do
            repository :test

            attribute :id,   Integer
            attribute :name, String

            key(*key_args)
          end
        end
      end

      context 'with a single key' do
        it_registers_relation
      end

      context 'with multiple keys' do
        let(:keys) { [:id, :name] }

        it_registers_relation
      end

      context 'defining relations' do
        before do
          stub(gateway).restrict(name: 'Jane') { gateway }

          schema.call do
            relation :restricted_users do
              users.restrict(name: 'Jane')
            end
          end
        end

        it 'registers restricted relation' do
          expect(schema[:restricted_users]).to be(gateway)
          expect(gateway).to have_received.restrict(name: 'Jane')
        end

        context 'when invalid relation name is used' do
          it 'raises error' do
            expect {
              schema.call do
                relation :restricted_users do
                  not_here.restrict
                end
              end
            }.to raise_error(NameError, /method `not_here'/)
          end
        end
      end
    end

    context 'without repository' do
      let(:schema) {
        described_class.new(test: repository).call do
          base_relation :users do
            attribute :id,   Integer
            attribute :name, String

            key :id
          end
        end
      }

      it 'raises an error' do
        expect { schema }.to raise_error(ArgumentError)
      end
    end
  end
end
