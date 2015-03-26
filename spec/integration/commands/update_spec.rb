require 'spec_helper'

require 'ostruct'

describe 'Commands / Update' do
  include_context 'users and tasks'

  subject(:users) { rom.commands.users }

  before do
    module Test
      User = Class.new

      UserValidator = Class.new do
        ValidationError = Class.new(ROM::CommandError)

        def self.call(params)
          raise ValidationError, ":email is required" unless params[:email]
        end
      end
    end

    setup.relation(:users) do
      def all(criteria)
        restrict(criteria)
      end

      def by_name(name)
        restrict(name: name)
      end
    end

    setup.commands(:users) do
      define(:update) do
        validator Test::UserValidator
      end
    end
  end

  it 'update tuples on successful validation' do
    result = users.try {
      users.update.all(name: 'Jane').set(email: 'jane.doe@test.com')
    }

    expect(result)
      .to match_array([{ name: 'Jane', email: 'jane.doe@test.com' }])
  end

  it 'returns validation object with errors on failed validation' do
    result = users.try { users.update.all(name: 'Jane').set(email: nil) }

    expect(result.error).to be_instance_of(Test::ValidationError)
    expect(result.error.message).to eql(':email is required')

    expect(rom.relations.users.restrict(name: 'Jane')).to match_array([
      { name: 'Jane', email: 'jane@doe.org' }
    ])
  end

  describe '"result" option' do
    context 'when set to :one' do
      context 'when there is one tuple' do
        it 'returns a single tuple' do
          setup.commands(:users) do
            define(:update_one, type: :update) do
              result :one
            end
          end

          result = users.try {
            users.update_one.by_name('Jane').set(email: 'jane.doe@test.com')
          }

          expect(result.value).to eql(name: 'Jane', email: 'jane.doe@test.com')
        end
      end

      context 'when there is more than one tuple' do
        it 'raises' do
          setup.commands(:users) do
            define(:update_one, type: :update) do
              result :one
            end
          end

          result = users.try {
            users.update_one.set(email: 'jane.doe@test.com')
          }

          expect(result.error).to be_instance_of(ROM::TupleCountMismatchError)

          expect(rom.relations.users).to match_array([
            { name: 'Jane', email: 'jane@doe.org' },
            { name: 'Joe', email: 'joe@doe.org' }
          ])
        end
      end
    end

    context 'when set to a Class' do
      let(:user) { double('Test::User') }

      before do
        allow(Test::User).to receive(:new).and_return(user)
      end

      it 'returns an instance of given Class' do
        setup.commands(:users) do
          define(:update_one, type: :update) do
            result Test::User
          end
        end

        result = users.try {
          users.update_one.by_name('Jane').set(email: 'jane.doe@test.com')
        }

        expect(Test::User).to have_received(:new).with(
          name: 'Jane',
          email: 'jane.doe@test.com'
        )
        expect(result.value).to eql(user)
      end
    end

    context 'when set to Array[Class]' do
      let(:user) { double('Test::User') }

      before do
        allow(Test::User).to receive(:new).and_return(user).twice
      end

      it 'returns a collection of instances of given Class' do
        setup.commands(:users) do
          define(:update_many, type: :update) do
            result Array[Test::User]
          end
        end

        result = users.try {
          users.update_many.set(email: 'jane.doe@test.com')
        }

        expect(Test::User).to have_received(:new).with(
          name: 'Joe',
          email: 'jane.doe@test.com'
        )
        expect(Test::User).to have_received(:new).with(
          name: 'Jane',
          email: 'jane.doe@test.com'
        )
        expect(result.value).to match_array([user, user])
      end
    end
  end
end
