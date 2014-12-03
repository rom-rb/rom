require 'spec_helper'

require 'ostruct'

describe 'Commands / Update' do
  include_context 'users and tasks'

  subject(:users) { rom.commands.users }

  before do
    UserParams = Class.new do
      include Virtus.model
      attribute :email
    end

    UserValidator = Class.new do
      def self.call(params)
        new.validate(params)
      end

      def initialize
        @errors = []
      end

      def validate(params)
        raise ArgumentError, ":email is required" unless params.email
      end
    end

    setup.relation(:users) do
      def all(criteria)
        restrict(criteria)
      end
    end

    setup.commands(:users) do
      define(:update) do
        input UserParams
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

    expect(result.error).to be_instance_of(ArgumentError)
    expect(result.error.message).to eql(':email is required')

    expect(rom.relations.users.restrict(name: 'Jane')).to match_array([
      { name: 'Jane', email: 'jane@doe.org' }
    ])
  end

end
