require 'spec_helper'

require 'ostruct'

describe 'Commands / Update' do
  include_context 'users and tasks'

  subject(:users) { rom.commands.users }

  before do
    UserValidator = Class.new do
      ValidationError = Class.new(ROM::CommandError)

      def self.call(params)
        raise ValidationError, ":email is required" unless params[:email]
      end
    end

    setup.relation(:users) do
      def all(criteria)
        restrict(criteria)
      end
    end

    setup.commands(:users) do
      define(:update) do
        input Hash
        validator UserValidator
      end
    end

  end

  it 'update tuples on successful validation' do
    result = users.try {
      update(:all, name: 'Jane').set(email: 'jane.doe@test.com')
    }

    expect(result).to match_array([{ name: 'Jane', email: 'jane.doe@test.com' }])
  end

  it 'returns validation object with errors on failed validation' do
    result = users.try { update(:all, name: 'Jane').set(email: nil) }

    expect(result.error).to be_instance_of(ValidationError)
    expect(result.error.message).to eql(':email is required')

    expect(rom.relations.users.restrict(name: 'Jane')).to match_array([
      { name: 'Jane', email: 'jane@doe.org' }
    ])
  end

end
