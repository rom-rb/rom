require 'spec_helper'

require 'ostruct'

describe 'Commands / Update' do
  include_context 'container'
  include_context 'users and tasks'

  subject(:users) { container.commands.users }

  before do
    module Test
      UserValidator = Class.new do
        ValidationError = Class.new(ROM::CommandError)

        def self.call(params)
          raise ValidationError, ":email is required" unless params[:email]
        end
      end
    end

    configuration.relation(:users) do
      register_as :users

      def all(criteria)
        restrict(criteria)
      end

      def by_name(name)
        restrict(name: name)
      end
    end

    configuration.commands(:users) do
      define(:update) do
        validator Test::UserValidator
      end
    end
  end

  it 'update tuples on successful validation' do
    result = users.try {
      users.update.all(name: 'Jane').call(email: 'jane.doe@test.com')
    }

    expect(result)
      .to match_array([{ name: 'Jane', email: 'jane.doe@test.com' }])
  end

  it 'returns validation object with errors on failed validation' do
    result = users.try { users.update.all(name: 'Jane').call(email: nil) }

    expect(result.error).to be_instance_of(Test::ValidationError)
    expect(result.error.message).to eql(':email is required')

    expect(container.relations.users.restrict(name: 'Jane')).to match_array([
      { name: 'Jane', email: 'jane@doe.org' }
    ])
  end

  describe '"result" option' do
    it 'returns a single tuple when set to :one' do
      configuration.commands(:users) do
        define(:update_one, type: :update) do
          result :one
        end
      end

      result = users.try {
        users.update_one.by_name('Jane').call(email: 'jane.doe@test.com')
      }

      expect(result.value).to eql(name: 'Jane', email: 'jane.doe@test.com')
    end

    it 'allows only valid result types' do
      expect {
        configuration.commands(:users) do
          define(:create_one, type: :create) do
            result :invalid_type
          end
        end
        container
      }.to raise_error(ROM::Options::InvalidOptionValueError)
    end
  end

  describe 'piping results through mappers' do
    it 'allows scoping to a virtual relation' do
      user_model = Class.new { include Anima.new(:name, :email) }

      configuration.mappers do
        define(:users) do
          model user_model
          register_as :entity
        end
      end

      command = container.command(:users).as(:entity).update.by_name('Jane')

      attributes = { name: 'Jane Doe', email: 'jane@doe.org' }
      result = command[attributes]

      expect(result).to eql([user_model.new(attributes)])
    end
  end
end
