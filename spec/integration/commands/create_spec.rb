require 'spec_helper'

describe 'Commands / Create' do
  include_context 'users and tasks'

  let(:users) { rom.commands.users }
  let(:tasks) { rom.commands.tasks }

  before do
    module Test
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

      def execute(task, user)
        super(task.merge(name: user.to_h[:name]))
      end
    end

    Test::User = Class.new do
      include Anima.new(:name, :email)
    end

    Test::Task = Class.new do
      include Anima.new(:name, :title)
    end

    class Test::UserMapper < ROM::Mapper
      relation :users
      register_as :entity
      model Test::User
      attribute :name
      attribute :email
    end

    class Test::TaskMapper < ROM::Mapper
      relation :tasks
      register_as :entity
      model Test::Task
      attribute :name
      attribute :title
    end
  end

  it 'inserts user on successful validation' do
    result = users.try {
      users.create.call(name: 'Piotr', email: 'piotr@solnic.eu')
    }

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

  describe 'sending result through a mapper' do
    let(:attributes) do
      { name: 'Jane', email: 'jane@doe.org' }
    end

    it 'uses registered mapper to process the result for :one result' do
      command = rom.command(:users).as(:entity).create
      result = command[attributes]

      expect(result).to eql(Test::User.new(attributes))
    end

    it 'with two composed commands respects the :result option' do
      mapper_input = nil

      mapper = proc do |tuples|
        mapper_input = tuples
      end

      left = rom.command(:users).as(:entity).create.with(
        name: 'Jane', email: 'jane@doe.org'
      )

      right = rom.command(:tasks).as(:entity).create.with(
        title: 'Jane task'
      )

      command = left >> right >> mapper

      result = command.call

      task = Test::Task.new(name: 'Jane', title: 'Jane task')

      expect(mapper_input).to eql([task])
      expect(result).to eql(task)
    end

    it 'uses registered mapper to process the result for :many results' do
      setup.commands(:users) do
        define(:create_many, type: :create)
      end

      command = rom.command(:users).as(:entity).create_many
      result = command[attributes]

      expect(result).to eql([Test::User.new(attributes)])
    end
  end
end
