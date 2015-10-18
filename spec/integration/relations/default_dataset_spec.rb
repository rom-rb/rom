require 'spec_helper'

describe ROM::Relation, '.dataset' do
  include_context 'users and tasks'

  it 'injects configured dataset when block was provided' do
    setup.relation(:users) do
      dataset { restrict(name: 'Jane') }
    end

    expect(rom.relation(:users).dataset).to eql(
      rom.relation(:users).dataset.restrict(name: 'Jane')
    )
  end
end
