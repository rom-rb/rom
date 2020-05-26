# frozen_string_literal: true

require 'spec_helper'
require 'dry-struct'

RSpec.describe 'Commands / Update' do
  include_context 'container'
  include_context 'users and tasks'

  subject(:users) { container.commands.users }

  before do
    configuration.relation(:users) do
      schema(:users) do
        attribute :name, ROM::Types::String
        attribute :email, ROM::Types::String
      end

      def all(criteria)
        restrict(criteria)
      end

      def by_name(name)
        restrict(name: name)
      end
    end

    configuration.commands(:users) do
      define(:update)
    end
  end

  it 'update tuples' do
    result = users.update.all(name: 'Jane').call(email: 'jane.doe@test.com')

    expect(result).to eql([{ name: 'Jane', email: 'jane.doe@test.com' }])
  end

  describe '"result" option' do
    it 'returns a single tuple when set to :one' do
      configuration.commands(:users) do
        define(:update_one, type: :update) do
          result :one
        end
      end

      result = users.update_one.by_name('Jane').call(email: 'jane.doe@test.com')

      expect(result).to eql(name: 'Jane', email: 'jane.doe@test.com')
    end

    it 'allows only valid result types' do
      expect {
        configuration.commands(:users) do
          define(:create_one, type: :create) do
            result :invalid_type
          end
        end
        container
      }.to raise_error(Dry::Types::ConstraintError)
    end
  end

  describe 'piping results through mappers' do
    it 'allows scoping to a virtual relation' do
      user_model = Class.new(Dry::Struct) {
        attribute :name, Types::String
        attribute :email, Types::String
      }

      configuration.mappers do
        define(:users) do
          model user_model
          register_as :entity
        end
      end

      command = container.commands[:users].map_with(:entity).update.by_name('Jane')

      attributes = { name: 'Jane Doe', email: 'jane@doe.org' }
      result = command[attributes]

      expect(result).to eql([user_model.new(attributes)])
    end
  end

  context 'custom input' do
    it "doesn't duplicate input schema when command chained" do
      input = ROM::Types::Hash.constructor(&:itself)

      configuration.commands(:users) do
        define(:update_one, input: input, type: :update)
      end

      relation = container.relations[:users]

      expect(users.update_one.new(relation).input).to be(users.update_one.input)
    end
  end
end
