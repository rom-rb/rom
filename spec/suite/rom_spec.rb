# frozen_string_literal: true

require "rom/sql/migration"

RSpec.describe ROM do
  describe "custom class with components" do
    subject(:repo) do
      Test::Repo.new
    end

    let(:gateway) do
      repo.gateways[:default]
    end

    before do
      module Test
        class Repo
          extend ROM(:sql, "sqlite::memory", as: :persistence)

          relation(:users) do
            schema do
              attribute :id, Types::Integer
              attribute :name, Types::String

              primary_key :id
            end
          end

          def create_user(params)
            relations[:users].changeset(:create, params).commit
          end
        end
      end
    end

    it "provides access to rom runtime" do
      expect(repo.persistence).to be_a(ROM::Container)
    end

    it "provides access to configured gateway" do
      expect(repo.gateways[:default]).to be_a(ROM::SQL::Gateway)
    end

    it "provides access to configured relations" do
      expect(repo.relations[:users]).to be_a(ROM::SQL::Relation)
    end

    it "just freaking works" do
      gateway.auto_migrate!(repo.persistence, inline: true)

      user = repo.create_user(name: "Jane")

      expect(user[:id]).to be_a(Integer)
      expect(user[:name]).to eql("Jane")
    end
  end
end
