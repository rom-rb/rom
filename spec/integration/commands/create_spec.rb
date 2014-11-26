require 'spec_helper'

describe 'Commands / Create' do
  include_context 'users and tasks'

  subject(:command) { rom.command(:users).create }

  before do
    UserParams = Class.new do
      include Virtus.model
      attribute :name
      attribute :email
    end

    UserValidator = Class.new do
      attr_reader :errors

      def self.call(params)
        new.validate(params)
      end

      def initialize
        @errors = []
      end

      def validate(params)
        @success = params.name && params.email
        errors << 'oops' unless success?
        self
      end

      def success?
        @success
      end
    end

    setup.relation(:users)

    setup.commands(:users) do
      define(:create) do
        input UserParams
        validator UserValidator
      end
    end

  end

  it 'inserts tuple on successful validation' do
    result = command.execute(name: 'Piotr', email: 'piotr@solnic.eu')

    expect(result).to match_array([{ name: 'Piotr', email: 'piotr@solnic.eu' }])
  end

  it 'returns validation object with errors on failed validation' do
    result = command.execute(name: 'Piotr')

    expect(result).to_not be_success
    expect(result.errors).to eql(['oops'])
    expect(rom.relations.users.count).to be(2)
  end

end
