require 'spec_helper'

describe 'Commands / Create' do
  include_context 'users and tasks'

  let(:users) { rom.commands.users }
  let(:tasks) { rom.commands.tasks }

  before do
    UserParams = Class.new do
      include Virtus.model
      attribute :name
      attribute :email

      def self.[](input)
        new(input)
      end
    end

    UserValidator = Class.new do
      ValidationError = Class.new(ROM::CommandError)

      def self.call(params)
        new.validate(params)
      end

      def validate(params)
        unless params.name && params.email
          raise ValidationError, ":name and :email are required"
        end
      end
    end

    TaskValidator = Class.new do
      def self.call(params)
        new.validate(params)
      end

      def validate(*)
        # noop
      end
    end

    setup.relation(:users)
    setup.relation(:tasks)

    setup.commands(:users) do
      define(:create) do
        input UserParams
        validator UserValidator
      end
    end

    setup.commands(:tasks) do
      define(:create) do
        input Hash
        validator TaskValidator
      end
    end

  end

  it 'inserts user on successful validation' do
    result = users.try { create(name: 'Piotr', email: 'piotr@solnic.eu') }

    expect(result).to match_array([{ name: 'Piotr', email: 'piotr@solnic.eu' }])
  end

  it 'inserts user and associated task when things go well' do
    result = users.try {
      create(name: 'Piotr', email: 'piotr@solnic.eu')
    } >-> users {
      tasks.try {
        create(name: users.first[:name], title: 'Finish command-api')
      }
    }

    expect(result).to match_array([{ name: 'Piotr', title: 'Finish command-api' }])
  end

  it 'returns validation object with errors on failed validation' do
    result = users.try { create(name: 'Piotr') }

    expect(result.error).to be_instance_of(ValidationError)
    expect(result.error.message).to eql(":name and :email are required")
    expect(rom.relations.users.count).to be(2)
  end

end
