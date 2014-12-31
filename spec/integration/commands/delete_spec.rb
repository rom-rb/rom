require 'spec_helper'

describe 'Commands / Delete' do
  include_context 'users and tasks'

  subject(:users) { rom.commands.users }

  before do
    setup.relation(:users) do
      def by_name(name)
        restrict(name: name)
      end
    end

    setup.commands(:users) do
      define(:delete)
    end
  end

  it 'deletes all tuples when there is no restriction' do
    result = users.try { delete }

    expect(result).to match_array([
      { name: 'Jane', email: 'jane@doe.org' },
      { name: 'Joe', email: 'joe@doe.org' }
    ])
  end

  it 'deletes tuples matching restriction' do
    result = users.try { delete(:by_name, 'Joe') }

    expect(result).to match_array([{ name: 'Joe', email: 'joe@doe.org' }])
  end

  it 'returns untouched relation if there are no tuples to delete' do
    result = users.try { delete(:by_name, 'Not here') }

    expect(result).to match_array([])
  end

  it 'returns deleted tuple when result is set to :one' do
    setup.commands(:users) do
      define(:delete_one, type: :delete) do
        result :one
      end
    end

    result = users.try { delete_one(:by_name, 'Jane') }

    expect(result.value).to eql(name: 'Jane', email: 'jane@doe.org')
  end

  it 'raises when result is set to :one and relation contains more tuples' do
    setup.commands(:users) do
      define(:delete) do
        result :one
      end
    end

    result = users.try { delete }

    expect(result.error).to be_instance_of(ROM::TupleCountMismatchError)

    expect(rom.relations.users.to_a).to match_array([
      { name: 'Jane', email: 'jane@doe.org' },
      { name: 'Joe', email: 'joe@doe.org' }
    ])
  end
end
