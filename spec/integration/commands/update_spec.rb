require 'spec_helper'

require 'ostruct'

describe 'Commands / Update' do
  include_context 'users and tasks'

  subject(:command) { rom.command(:users).update(:all, name: 'Jane') }

  before do
    UserParams = Class.new(OpenStruct)

    UserValidator = Class.new do
      attr_reader :errors

      def self.call(params)
        new.validate(params)
      end

      def initialize
        @errors = []
      end

      def validate(params)
        @success = !params.email.nil?
        errors << 'oops' unless success?
        self
      end

      def success?
        @success
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

  it 'inserts tuple on successful validation' do
    result = command.execute(email: 'jane.doe@test.com')

    expect(result).to match_array([{ name: 'Jane', email: 'jane.doe@test.com' }])
  end

  it 'returns validation object with errors on failed validation' do
    result = command.execute(email: nil)

    expect(result.all?(&:success?)).to_not be(true)
    expect(result.first.errors).to eql(['oops'])

    expect(rom.relations.users.restrict(name: 'Jane')).to match_array([
      { name: 'Jane', email: 'jane@doe.org' }
    ])
  end

end
