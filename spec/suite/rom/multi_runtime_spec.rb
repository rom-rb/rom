# frozen_string_literal: true

require "rom/runtime"

RSpec.describe "Setting up ROM with multiple runtimes" do
  let(:runtime) do
    {one: ROM::Runtime.new(:memory), two: ROM::Runtime.new(:memory)}
  end

  let(:resolvers) do
    {one: runtime[:one].finalize, two: runtime[:two].finalize}
  end

  context "without :auto_registration plugin" do
    before do
      module Test
        class Users < ROM::Relation[:memory]
          schema(:users) {}
        end

        class CreateUser < ROM::Commands::Create[:memory]
          config.component.id = :create
          config.component.namespace = :users
          config.component.relation = :users
          config.result = :one
        end

        class UserMapper < ROM::Mapper
          config.component.id = :entity
          config.component.namespace = :users
        end
      end
    end

    it "registers items independently of other environments" do
      runtime[:one].register_relation(Test::Users)
      runtime[:one].register_command(Test::CreateUser)
      runtime[:one].register_mapper(Test::UserMapper)

      expect(resolvers[:one].relations[:users]).to be_kind_of Test::Users
      expect(resolvers[:one].commands[:users][:create]).to be_kind_of Test::CreateUser
      expect(resolvers[:one].mappers[:users][:entity]).to be_kind_of Test::UserMapper

      expect { resolvers[:two].relations[:users] }.to raise_error(
        ROM::ElementNotFoundError
      )
      expect { resolvers[:two].commands[:users][:create] }.to raise_error(
        ROM::ElementNotFoundError
      )
      expect { resolvers[:two].commands[:users][:create] }.to raise_error(
        ROM::ElementNotFoundError
      )
    end

    it "allows use of the same identifiers in different environments" do
      runtime[:one].register_relation(Test::Users)
      runtime[:one].register_command(Test::CreateUser)
      runtime[:one].register_mapper(Test::UserMapper)

      expect { runtime[:two].register_relation(Test::Users) }.to_not raise_error
      expect { runtime[:two].register_command(Test::CreateUser) }.to_not raise_error
      expect { runtime[:two].register_mapper(Test::UserMapper) }.to_not raise_error
    end
  end

  context "with associations" do
    before do
      module Test
        class Users < ROM::Relation[:memory]
          schema(:users) do
            attribute :id, ROM::Types::Integer
            attribute :name, ROM::Types::String
          end

          associations do
            has_many :tasks
          end
        end

        class Tasks < ROM::Relation[:memory]
          schema(:tasks) do
            attribute :id, ROM::Types::Integer
            attribute :title, ROM::Types::String
            attribute :user_id, ROM::Types::Integer
          end

          associations do
            belongs_to :user
          end
        end
      end
    end

    it "separates associations between different runtimes" do
      runtime[:one].register_relation(Test::Users)
      runtime[:one].register_relation(Test::Tasks)

      runtime[:two].register_relation(Test::Users)
      runtime[:two].register_relation(Test::Tasks)

      expect(
        resolvers[:one].relations[:users].schema.associations
      ).not_to be(resolvers[:two].relations[:users].associations)
    end
  end
end
