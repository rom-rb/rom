require 'spec_helper'

describe 'Setting up ROM with multiple environments' do
  let(:environment) do
    {
      one: ROM::Environment.new,
      two: ROM::Environment.new
    }
  end
  let(:setup) do
    {
      one: environment[:one].setup(:memory),
      two: environment[:two].setup(:memory)
    }
  end
  let(:container) do
    {
      one: setup[:one].finalize,
      two: setup[:two].finalize
    }
  end

  before { setup }

  context 'without :auto_registration plugin' do
    before do
      module Test
        class Users < ROM::Relation[:memory]
          dataset :users
        end

        class CreateUser < ROM::Commands::Create[:memory]
          register_as :create
          relation :users
          result :one
        end

        class UserMapper < ROM::Mapper
          relation :users
          register_as :entity
        end
      end
    end

    it 'registers items independently of other environments' do
      environment[:one].register_relation(Test::Users)
      environment[:one].register_command(Test::CreateUser)
      environment[:one].register_mapper(Test::UserMapper)

      expect(container[:one].relations[:users]).to be_kind_of Test::Users
      expect(container[:one].commands[:users].create).to be_kind_of Test::CreateUser
      expect(container[:one].mappers[:users].entity).to be_kind_of Test::UserMapper

      expect { container[:two].relations[:users] }.to raise_error(
        ROM::Registry::ElementNotFoundError
      )
      expect { container[:two].commands[:users].create }.to raise_error(
        ROM::Registry::ElementNotFoundError
      )
      expect { container[:two].commands[:users].create }.to raise_error(
        ROM::Registry::ElementNotFoundError
      )
    end

    it 'allows use of the same identifiers in different environments' do
      environment[:one].register_relation(Test::Users)
      environment[:one].register_command(Test::CreateUser)
      environment[:one].register_mapper(Test::UserMapper)

      expect { environment[:two].register_relation(Test::Users) }.to_not raise_error
      expect { environment[:two].register_command(Test::CreateUser) }.to_not raise_error
      expect { environment[:two].register_mapper(Test::UserMapper) }.to_not raise_error
    end
  end

  context 'with :auto_registration plugin' do
    context 'without if option' do
      before do
        environment[:one].use :auto_registration

        module Test
          class Users < ROM::Relation[:memory]
            dataset :users
          end

          class CreateUser < ROM::Commands::Create[:memory]
            register_as :create
            relation :users
            result :one
          end

          class UserMapper < ROM::Mapper
            relation :users
            register_as :entity
          end
        end
      end

      it 'registers all classes that are defined with the given environment' do
        expect(container[:one].relations[:users]).to be_kind_of Test::Users
        expect(container[:one].commands[:users].create).to be_kind_of Test::CreateUser
        expect(container[:one].mappers[:users].entity).to be_kind_of Test::UserMapper
      end

      it 'works independently of other environments' do
        expect { container[:two].relations[:users] }.to raise_error(
          ROM::Registry::ElementNotFoundError
        )
        expect { container[:two].commands[:users].create }.to raise_error(
          ROM::Registry::ElementNotFoundError
        )
        expect { container[:two].commands[:users].create }.to raise_error(
          ROM::Registry::ElementNotFoundError
        )
      end
    end

    context 'with if option' do
      before do
        environment[:one].use :auto_registration, if: ->(item) do
          item.to_s[/(.*)(?=::)/] == 'Test'
        end

        environment[:two].use :auto_registration, if: ->(item) do
          item.to_s[/(.*)(?=::)/] == 'Test::API'
        end

        module Test
          class Users < ROM::Relation[:memory]
            dataset :users
          end

          class CreateUser < ROM::Commands::Create[:memory]
            register_as :create
            relation :users
            result :one
          end

          class UserMapper < ROM::Mapper
            relation :users
            register_as :entity
          end

          module API
            class Users < ROM::Relation[:memory]
              dataset :users
            end

            class CreateUser < ROM::Commands::Create[:memory]
              register_as :create
              relation :users
              result :one
            end

            class UserMapper < ROM::Mapper
              relation :users
              register_as :entity
            end
          end
        end
      end

      it 'registers all classes that are defined where proc returns true' do
        expect(container[:one].relations[:users]).to be_kind_of Test::Users
        expect(container[:one].commands[:users].create).to be_kind_of Test::CreateUser
        expect(container[:one].mappers[:users].entity).to be_kind_of Test::UserMapper
        expect(container[:two].relations[:users]).to be_kind_of Test::API::Users
        expect(container[:two].commands[:users].create).to be_kind_of(
          Test::API::CreateUser
        )
        expect(container[:two].mappers[:users].entity).to be_kind_of(
          Test::API::UserMapper
        )
      end
    end
  end
end
