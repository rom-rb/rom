require 'spec_helper'

describe 'Working with relations' do
  let(:header) { Axiom::Relation::Header.coerce([[:id, Integer], [:name, String]]) }
  let(:mapper) { TestMapper.new(header, model) }
  let(:model)  { Class.new(OpenStruct) }

  specify 'relation setup' do
    env  = ROM::Environment.coerce(:test => 'memory://test')
    repo = env.repository(:test)

    repo.register(:users, Axiom::Relation::Base.new(:users, header))

    users = ROM::Relation.new(repo.get(:users), mapper)

    user = model.new(id: 1, name: 'Jane')

    # TODO: change this to check original relation once Relation::Variable
    expect(users.insert(user).all).to include(user)
  end
end
