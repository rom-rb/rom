require 'spec_helper'

describe 'Commands / Create' do
  include_context 'users and tasks'

  let(:users) { rom.commands.users }
  let(:tasks) { rom.commands.tasks }

  before do
    module Test
      User = Class.new

      UserValidator = Class.new do
        ValidationError = Class.new(ROM::CommandError)

        def self.call(params)
          unless params[:name] && params[:email]
            raise ValidationError, ":name and :email are required"
          end
        end
      end
    end

    setup.relation(:users)
    setup.relation(:tasks)

    class Test::CreateUser < ROM::Commands::Create[:memory]
      relation :users
      register_as :create
      result :one
      validator Test::UserValidator
    end

    class Test::CreateTask < ROM::Commands::Create[:memory]
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

    expect(result.error).to be_instance_of(Test::ValidationError)
    expect(result.error.message).to eql(":name and :email are required")
    expect(rom.relations.users.count).to be(2)
  end

  describe '"result" option' do
    context 'when set to :one' do
      it 'returns a single tuple' do
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
    end

    context 'when set to a Class' do
      let(:user) { double('Test::User') }

      before do
        allow(Test::User).to receive(:new).and_return(user)
      end

      it 'returns an instance of given Class' do
        setup.commands(:users) do
          define(:create_one, type: :create) do
            result Test::User
          end
        end

        tuple = { name: 'Piotr', email: 'piotr@solnic.eu' }

        result = users.try {
          users.create_one.call(tuple)
        }

        expect(Test::User).to have_received(:new).with(tuple)
        expect(result.value).to eql(user)
      end
    end

    context 'when set to Array[Class]' do
      let(:user) { double('Test::User') }

      before do
        allow(Test::User).to receive(:new).and_return(user)
      end

      it 'returns a collection of instances of given Class' do
        setup.commands(:users) do
          define(:create_many, type: :create) do
            result Array[Test::User]
          end
        end

        tuple = { name: 'Piotr', email: 'piotr@solnic.eu' }

        result = users.try {
          users.create_many.call(tuple)
        }

        expect(Test::User).to have_received(:new).with(tuple)
        expect(result.value).to match_array([user])
      end
    end
  end
end
