require 'spec_helper'

describe 'Commands / Delete' do
  include_context 'users and tasks'

  subject(:users) { rom.commands.users }

  before do
    module Test
      User = Class.new
    end

    setup.relation(:users) do
      def by_name(name)
        restrict(name: name)
      end
    end
  end

  context 'when there is no restriction' do
    it 'deletes all tuples' do
      setup.commands(:users) do
        define(:delete)
      end

      result = users.try { users.delete.call }

      expect(result).to match_array([
        { name: 'Jane', email: 'jane@doe.org' },
        { name: 'Joe', email: 'joe@doe.org' }
      ])
    end
  end

  context 'when there are restrictions' do
    it 'deletes tuples matching restriction' do
      setup.commands(:users) do
        define(:delete)
      end

      result = users.try { users.delete.by_name('Joe').call }

      expect(result).to match_array([{ name: 'Joe', email: 'joe@doe.org' }])
    end
  end

  context 'when there are no tuples to delete' do
    it 'returns untouched relation' do
      setup.commands(:users) do
        define(:delete)
      end

      result = users.try { users.delete.by_name('Not here').call }

      expect(result).to match_array([])
    end
  end

  context 'when result is set to :one' do
    context 'when there is one tuple' do
      it 'returns deleted tuple' do
        setup.commands(:users) do
          define(:delete_one, type: :delete) do
            result :one
          end
        end

        result = users.try { users.delete_one.by_name('Jane').call }

        expect(result.value).to eql(name: 'Jane', email: 'jane@doe.org')
      end
    end

    context 'when there is more than one tuple' do
      it 'raises' do
        setup.commands(:users) do
          define(:delete) do
            result :one
          end
        end

        result = users.try { users.delete.call }

        expect(result.error).to be_instance_of(ROM::TupleCountMismatchError)

        expect(rom.relations.users.to_a).to match_array([
          { name: 'Jane', email: 'jane@doe.org' },
          { name: 'Joe', email: 'joe@doe.org' }
        ])
      end
    end
  end

  context 'when result is set to a Class' do
    let(:user) { double('Test::User') }

    before do
      allow(Test::User).to receive(:new).and_return(user)
    end

    it 'returns deleted tuple as instance of the given Class' do
      setup.commands(:users) do
        define(:delete_one, type: :delete) do
          result Test::User
        end
      end

      result = users.try { users.delete_one.by_name('Jane').call }

      expect(Test::User).to have_received(:new).with(
        name: 'Jane',
        email: 'jane@doe.org'
      )
      expect(result.value).to eql(user)
    end
  end

  context 'when set to Array[Class]' do
    let(:user) { double('Test::User') }

    before do
      allow(Test::User).to receive(:new).and_return(user).twice
    end

    it 'returns deleted tuple as instance of the given Class' do
      setup.commands(:users) do
        define(:delete_many, type: :delete) do
          result Array[Test::User]
        end
      end

      result = users.try { users.delete_many.call }

      expect(Test::User).to have_received(:new).with(
        name: 'Joe',
        email: 'joe@doe.org'
      )
      expect(Test::User).to have_received(:new).with(
        name: 'Jane',
        email: 'jane@doe.org'
      )
      expect(result.value).to match_array([user, user])
    end
  end
end
