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

    class CreateUser < ROM::Commands::Create[:memory]
      relation :users
      register_as :create
      result :one
      validator UserValidator
    end

    class CreateTask < ROM::Commands::Create[:memory]
      relation :tasks
      register_as :create
      result :one

      def execute(user, task)
        super(task.merge(name: user[:name]))
      end
    end
  end

  it 'inserts user on successful validation' do
    result = users.try do
      users.create.call(name: 'Piotr', email: 'piotr@solnic.eu')
    end

    expect(result.value).to eql(name: 'Piotr', email: 'piotr@solnic.eu')
  end

  it 'inserts user and associated task when things go well' do
    result = users.try {
      command = users.create.with(name: 'Piotr', email: 'piotr@solnic.eu')
      command >>= tasks.create.with(title: 'Finish command-api')
      command
    }

    expect(result.value).to eql(name: 'Piotr', title: 'Finish command-api')
  end

  it 'returns validation object with errors on failed validation' do
    result = users.try { users.create.call(name: 'Piotr') }

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
        users.create_one.call(tuple)
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
