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

    expect(result).to match_array([])
  end

  it 'deletes tuples matching restriction' do
    result = users.try { delete(:by_name, 'Joe').execute }

    expect(result).to match_array([{ name: 'Jane', email: 'jane@doe.org' }])
  end

  it 'returns untouched relation if there are no tuples to delete' do
    result = users.try { delete(:by_name, 'Not here').execute }

    expect(result).to match_array([
      { name: 'Jane', email: 'jane@doe.org' },
      { name: 'Joe', email: 'joe@doe.org' }
    ])
  end

end
