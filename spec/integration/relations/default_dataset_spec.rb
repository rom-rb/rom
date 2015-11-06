require 'spec_helper'

describe ROM::Relation, '.dataset' do
  include_context 'users and tasks'

  it 'injects configured dataset when block was provided' do
    configuration.relation(:users) do
      dataset { restrict(name: 'Jane') }
    end

    expect(container.relation(:users).dataset).to eql(
      container.relation(:users).dataset.restrict(name: 'Jane')
    )
  end
end
