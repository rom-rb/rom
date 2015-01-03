require 'spec_helper'

describe 'Commands / Create' do
  include_context 'users and tasks'

  let(:users) { rom.commands.users }
  let(:tasks) { rom.commands.tasks }

  before do
    UserValidator = Class.new do
      ValidationError = Class.new(ROM::CommandError)

      def self.call(params)
        unless params[:name] && params[:email]
          raise ValidationError, ":name and :email are required"
        end
      end
    end

    setup.relation(:users)
    setup.relation(:tasks)

    setup.commands(:users) do
      define(:create) do
        validator UserValidator
      end
    end

    setup.commands(:tasks) do
      define(:create)
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

    expect(result)
      .to match_array([{ name: 'Piotr', title: 'Finish command-api' }])
  end

  it 'returns validation object with errors on failed validation' do
    result = users.try { create(name: 'Piotr') }

    expect(result.error).to be_instance_of(ValidationError)
    expect(result.error.message).to eql(":name and :email are required")
    expect(rom.relations.users.count).to be(2)
  end

  describe '"result" option' do
    it 'returns a single tuple when set to :one' do
      setup.commands(:users) do
        define(:create_one, type: :create) do
          result :one
        end
      end

      tuple = { name: 'Piotr', email: 'piotr@solnic.eu' }

      result = users.try {
        create_one(tuple)
      }

      expect(result.value).to eql(tuple)
    end

    it 'allows only valid result types' do
      expect {
        setup.commands(:users) do
          define(:create_one, type: :create) do
            result :invalid_type
          end
        end
        setup.finalize
      }.to raise_error(ROM::InvalidOptionValueError)
    end
  end
end
